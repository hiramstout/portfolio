<?php

namespace App\Services\ImageModerationService;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\Arachnid\DTOs\MatchTypeEnum;
use App\Services\ImageModerationService\Arachnid\DTOs\ScanResultClassificationEnum;
use App\Services\ImageModerationService\Arachnid\ProjectArachnidService;
use App\Services\ImageModerationService\AWSRekognition\DTOs\Image\Image;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeRequest;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationRequest;
use App\Services\ImageModerationService\AWSRekognition\RekognitionServiceClient;
use App\Services\ImageModerationService\CloudVisionAI\CloudVisionAIService;
use App\Services\ImageModerationService\CloudVisionAI\DTOs\LikelihoodEnum;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ImageUrl\ImageUrl;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ModerationInput;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInputCollection;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationRequest;
use App\Services\ImageModerationService\OpenAIImageModeration\OpenAIImageModerationClient;
use App\Services\ImageModerationService\SightEngine\SightEngineApiClient;
use Exception;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabelEnum;

class ImageModerationService
{
    // TODO: Implement text moderation
    protected ProjectArachnidService $arachnidService;
    protected CloudVisionAIService $cloudVisionAIService;
    protected RekognitionServiceClient $rekognitionClient;
    protected OpenAIImageModerationClient $openAIImageModerationClient;
    protected SightEngineApiClient $sightEngineApiClient;

    private string $fileName = 'ImageModerationService.php';
    private ?PolyamoryMatchExceptionEnum $exceptionType = null;

    public function __construct() {
        $this->arachnidService = new ProjectArachnidService();
        $this->cloudVisionAIService = new CloudVisionAIService();
        $this->rekognitionClient = new RekognitionServiceClient();
        $this->openAIImageModerationClient = new OpenAIImageModerationClient();
        $this->sightEngineApiClient = new SightEngineApiClient();
    }

    /**
     * @throws ConnectionException
     * @throws PolyamoryMatchException
     */
    public function moderateImage(
        UploadedFile $picture,
        bool         $includeSightEngine = true
    ) {
        $funcName = 'moderateImage';
        try {
            $scanMediaResponse = $this ->arachnidService ->scanMediaFile($picture);
        } catch (Exception $e) {
            $exceptionType = PolyamoryMatchExceptionEnum::CSAMAPIUnreachable;

            Log::critical('Arachnid API request failed: ' . $e->getMessage());
            throw new PolyamoryMatchException(
                $exceptionType,
                $e->getMessage(),
                $this -> fileName,
                'moderateImage',
                $e
            );
        }
        if ($scanMediaResponse->classification == ScanResultClassificationEnum::CSAM
            || $scanMediaResponse->classification == ScanResultClassificationEnum::HarmfulAbusiveMaterial
        ) {
            $path = $picture->store('CSAM_Quarantine', 'private');

            $user = Auth::user();
            $user->forgetCachedPermissions();
            auth()->user()->update([
                'password' => Hash::make('CSAM Quarantine')
            ]);
            auth()->forgetUser();

            switch ($scanMediaResponse->classification) {
                case ScanResultClassificationEnum::HarmfulAbusiveMaterial:
                    $this->exceptionType = PolyamoryMatchExceptionEnum::CSAMHarmfulAbusive;
                    break;
                case ScanResultClassificationEnum::CSAM:
                    switch ($scanMediaResponse->matchType) {
                        case MatchTypeEnum::exact:
                            $this->exceptionType = PolyamoryMatchExceptionEnum::KnownCSAMDetected;
                            break;
                        case MatchTypeEnum::near:
                            $this->exceptionType = PolyamoryMatchExceptionEnum::PossibleKnownCSAMDetected;
                    }
                    break;
                default:
                    throw new PolyamoryMatchException(
                        $this->exceptionType,
                        'Unexpected exception',
                        $this->fileName,
                        'moderateImage'
                    );
            }
            $errorInfoArray = [
                'File Path' => $path,
                'Classification' => $scanMediaResponse->classification->label(),
                'Match AiDetectionType' => $scanMediaResponse->matchType->label(),
                'Match Details' => $scanMediaResponse->nearMatchDetails->all(),
                'Sha1 Base 32' => $scanMediaResponse->sha1_base32,
                'Sha256 Hex' => $scanMediaResponse->sha256_hex,
                'Size Bytes' => $scanMediaResponse->size_bytes
            ];
            $errorMessage = 'CSAM detected, file has been placed in quarantine.'
                . ' User account disabled, please report this incident to the '
                . 'authorities immediately.';

            Log::critical($errorMessage, $errorInfoArray);

            throw new PolyamoryMatchException(
                $this->exceptionType,
                $errorMessage . implode(PHP_EOL, $errorInfoArray),
                $this->fileName,
                'moderateImage',
            );

        }
        Log::debug('Arachnid API request successful', (array)$scanMediaResponse);


        // Google Vision AI Safe search image moderation request, response & analysis
        $safeSearchResponse = $this->cloudVisionAIService->getSafeSearchAnnotationForImage($picture);
        if ($safeSearchResponse->violence->severity() >= LikelihoodEnum::likely->severity()) {
            $this->exceptionType = PolyamoryMatchExceptionEnum::ViolentContent;
        } elseif ($safeSearchResponse->spoof->severity() >= LikelihoodEnum::likely->severity()) {
            $this->exceptionType = PolyamoryMatchExceptionEnum::AiOrDoctoredImage;
        }
        if ($this->exceptionType) {
            $errorMessage = 'Image violates moderation requirements ('
                            . $this->exceptionType->getLabel() . ')'
                            . ' Service: CloudVisionAI';
            Log::alert($errorMessage);
            throw new PolyamoryMatchException(
                $this->exceptionType,
                $errorMessage,
                $this->fileName,
                $funcName
            );
        }
        Log::debug('Google Vision AI SafeSearch request successful: ', (array)$safeSearchResponse);

        try {
            // AWS Rekognition Image Moderation
            $rekognitionRequest = new RekognitionModerationRequest(
                image: new Image(
                    bytes: base64_encode($picture->getContent())
                ),
                minConfidence: 65
            );
            $awsResponse = $this
                ->rekognitionClient
                ->getRekognitionImageModeration($rekognitionRequest);
            foreach ($awsResponse->moderationLabelsCollection as $label) {
                if (in_array($label->name,[
                    ModerationLabelEnum::explicitSexualActivity,
                    ModerationLabelEnum::exposedButtocksOrAnus,
                    ModerationLabelEnum::exposedFemaleGenitalia,
                    ModerationLabelEnum::exposedFemaleNipple,
                    ModerationLabelEnum::exposedMaleGenitalia,
                    ModerationLabelEnum::impliedNudity,
                    ModerationLabelEnum::obstructedFemaleNipple,
                    ModerationLabelEnum::obstructedMaleGenitalia,
                    ModerationLabelEnum::partiallyExposedButtocks,
                    ModerationLabelEnum::partiallyExposedFemaleBreast,
                    ModerationLabelEnum::sexToys
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::AdultContent;
                } elseif (in_array($label->name,[
                    ModerationLabelEnum::bloodAndGore,
                    ModerationLabelEnum::explosionsAndBlasts,
                    ModerationLabelEnum::physicalViolence,
                    ModerationLabelEnum::weaponViolence
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::ViolentContent;
                } elseif (in_array($label->name,[
                    ModerationLabelEnum::airCrash,
                    ModerationLabelEnum::corpses,
                    ModerationLabelEnum::emaciatedBodies,
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::VisuallyDisturbing;
                } elseif (in_array($label->name,[
                    ModerationLabelEnum::naziParty,
                    ModerationLabelEnum::whiteSupremacy,
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::HateContent;
                } elseif ($label->name == ModerationLabelEnum::pills) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::ContrabandContent;
                } elseif ($label->name == ModerationLabelEnum::gambling ) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::Gambling;
                } elseif ($label->name == ModerationLabelEnum::selfHarm) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::SelfHarm;
                } elseif ($label->name == ModerationLabelEnum::weapons) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::WeaponryContent;
                } elseif ($label->name == ModerationLabelEnum::animated){
                    $this->exceptionType = PolyamoryMatchExceptionEnum::AiOrDoctoredImage;
                } else {
                    break;
                }
                $errorMessage = 'Image violates moderation requirements ('
                                . $this->exceptionType->getLabel() . ')'
                                . ' Service: Rekognition';
                Log::alert($errorMessage);
                throw new PolyamoryMatchException(
                    $this->exceptionType,
                    $errorMessage,
                    $this->fileName,
                    $funcName
                );
            }
            foreach ($awsResponse->contentTypes as $contentType) {
                if (in_array($contentType->name,[
                    ModerationLabelEnum::explicitSexualActivity,
                    ModerationLabelEnum::exposedButtocksOrAnus,
                    ModerationLabelEnum::exposedFemaleGenitalia,
                    ModerationLabelEnum::exposedFemaleNipple,
                    ModerationLabelEnum::exposedMaleGenitalia,
                    ModerationLabelEnum::impliedNudity,
                    ModerationLabelEnum::obstructedFemaleNipple,
                    ModerationLabelEnum::obstructedMaleGenitalia,
                    ModerationLabelEnum::partiallyExposedButtocks,
                    ModerationLabelEnum::partiallyExposedFemaleBreast,
                    ModerationLabelEnum::sexToys
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::AdultContent;
                } elseif (in_array($contentType->name,[
                    ModerationLabelEnum::bloodAndGore,
                    ModerationLabelEnum::explosionsAndBlasts,
                    ModerationLabelEnum::physicalViolence,
                    ModerationLabelEnum::weaponViolence
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::ViolentContent;
                } elseif (in_array($contentType->name,[
                    ModerationLabelEnum::airCrash,
                    ModerationLabelEnum::corpses,
                    ModerationLabelEnum::emaciatedBodies,
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::VisuallyDisturbing;
                } elseif (in_array($contentType->name,[
                    ModerationLabelEnum::naziParty,
                    ModerationLabelEnum::whiteSupremacy,
                ])) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::HateContent;
                } elseif ($contentType->name == ModerationLabelEnum::pills) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::ContrabandContent;
                } elseif ($contentType->name == ModerationLabelEnum::gambling ) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::Gambling;
                } elseif ($contentType->name == ModerationLabelEnum::selfHarm) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::SelfHarm;
                } elseif ($contentType->name == ModerationLabelEnum::weapons) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::WeaponryContent;
                } elseif ($contentType->name == ModerationLabelEnum::animated){
                    $this->exceptionType = PolyamoryMatchExceptionEnum::AiOrDoctoredImage;
                } else {
                    break;
                }
                $errorMessage = 'Image violates moderation requirements ('
                                . $this->exceptionType->getLabel() . ')'
                                . ' Service: Rekognition';
                Log::alert($errorMessage);
                throw new PolyamoryMatchException(
                    $this->exceptionType,
                    $errorMessage,
                    fileName: $this->fileName,
                    funcName: $funcName
                );
            }
            Log::debug('Rekognition moderation request successful: ', (array)$awsResponse);

            // AWS Facial Recognition Age Range Request
            $awsAgeRangeResponse = $this
                ->rekognitionClient
                ->getRekognitionFacialDetectionAgeRange(
                    new RekognitionFacialDetectionAgeRangeRequest(
                        image: new Image(
                            bytes: base64_encode($picture->getContent())
                        )
                    )
                );

            foreach ($awsAgeRangeResponse->faceDetails as $faceDetail) {
                if ($faceDetail->ageRange->high < 18) {
                    $this->exceptionType = PolyamoryMatchExceptionEnum::ChildrenPresent;
                    $errorMessage = 'Image violates moderation requirements ('
                                    . $this->exceptionType->getLabel() . ')'
                                    . 'Service: RekognitionAgeRange';
                    Log::alert($errorMessage);
                    throw new PolyamoryMatchException(
                        $this->exceptionType,
                        $errorMessage,
                        $this->fileName,
                        $funcName
                    );
                }
            }
            Log::debug('Rekognition age range request successful: ', (array)$awsAgeRangeResponse);
        } catch (PolyamoryMatchException $e) {
            if (
                $e->exceptionType != PolyamoryMatchExceptionEnum::ModerationServiceInvalidFormat
                && $e->exceptionType != PolyamoryMatchExceptionEnum::ModerationServiceImageTooLarge
            ) {
                throw $e;
            }
        } catch (Exception $e) {
            $errorMessage = 'Rekognition request failed';
            Log::alert($errorMessage);
            throw new PolyamoryMatchException(
                $this->exceptionType,
                $errorMessage,
                $this->fileName,
                $funcName,
                $e
            );
        }

        try {
            // OpenAI Image Moderation
            $openAiResponse = $this
                ->openAIImageModerationClient
                ->getModerationRequestResponse(
                    new ModerationRequest(
                        new ModerationInputCollection(
                            new ModerationInput(
                                new ImageUrl(
                                    $picture,
                                )
                            )
                        )
                    )
                )
            ;
            foreach ( $openAiResponse->results as $result ) {
                if ( $result->flagged ) {
                    $categories = $result->categories;
                    if ( $categories->sexual ) {
                        $this->exceptionType = PolyamoryMatchExceptionEnum::AdultContent;
                    } elseif (
                        $categories->selfHarm
                        || $categories->selfHarmIntent
                        || $categories->selfHarmInstructions
                    ) {
                        $this->exceptionType = PolyamoryMatchExceptionEnum::SelfHarm;
                    } elseif (
                        $categories->violence
                        || $categories->violenceGraphic
                    ) {
                        $this->exceptionType = PolyamoryMatchExceptionEnum::ViolentContent;
                    } else {
                        break;
                    }
                    $errorMessage = 'Image violates moderation requirements ('
                                    . $this->exceptionType->getLabel() . ')'
                                    . 'Service: OpenAI';
                    Log::alert($errorMessage);
                    throw new PolyamoryMatchException(
                        $this->exceptionType,
                        $errorMessage,
                        $this->fileName,
                        $funcName
                    );

                }
                // TODO: If user has previously violated image moderation, lower threshold on violation detection.
                // if ($user->imageModerationViolations > 0) {
                // $result->categoryScores
                // }
            }

            Log::debug('OpenAI image moderation request successful: ', [
                "id"    => $openAiResponse->id,
                "model" => $openAiResponse->model,
                $openAiResponse->results->toArray()
            ]);
        } catch (\Exception $e) {
            $errorMessage = 'Rekognition request failed';
            Log::debug('OpenAI image moderation request unsuccessful: ', [
                "id"    => $errorMessage
            ]);
        }

        if ($includeSightEngine) {
            // Sight Engine Image moderation request
            $sightEngineResponse = $this
                ->sightEngineApiClient
                ->getImageModerationResponse(
                    $picture
                )
            ;

            if ( $sightEngineResponse->aiDetectionType->aiGenerated > 0.65 ) {
                $this->exceptionType = PolyamoryMatchExceptionEnum::AiOrDoctoredImage;
            } elseif ( $sightEngineResponse->military->prob > 0.65 ) {
                $this->exceptionType = PolyamoryMatchExceptionEnum::Military;
            }
            if ( $this->exceptionType ) {
                $errorMessage = 'Image violates moderation requirements ('
                                . $this->exceptionType->getLabel() . ')'
                                . 'Service: SightEngine';
                Log::alert($errorMessage);
                throw new PolyamoryMatchException(
                    $this->exceptionType,
                    $errorMessage,
                    $this->fileName,
                    $funcName
                );
            }

            Log::debug('Sight Engine request successful: ', (array)$sightEngineResponse);
        }
    }

    // TODO: Standardize image moderation with protected function
}
