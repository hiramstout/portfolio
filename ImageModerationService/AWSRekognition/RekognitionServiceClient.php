<?php

namespace App\Services\ImageModerationService\AWSRekognition;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeRequest;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\RekognitionFacialDetectionAgeRangeResponse;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationRequest;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationResponse;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RekognitionServiceClient {
    protected AWSAuthServiceClient $awsAuthService;
    protected string $region;
    protected string $service = "rekognition";
    private string $fileName = "RekognitionServicClient.php";

    public function __construct() {
        $accessKey = config("aws-rekognition.accessKeyId");
        $secretKey = trim(config("aws-rekognition.secretAccessKey"));
        $region = config("aws-rekognition.region");
        $this->awsAuthService = new AWSAuthServiceClient(
            accessKey: $accessKey,
            secretKey: $secretKey,
            region: $region
        );
        $this->region = $region;
    }

    /**
     * @throws PolyamoryMatchException|ConnectionException
     */
    public function getRekognitionImageModeration(
        RekognitionModerationRequest $request
    ): ModerationResponse {
        $totalBytes = strlen($request->image->bytes);
        if ( $totalBytes >= 5242880) {
            $message = "Rekognition Image Moderation request failed";
            Log::alert($message);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::ModerationServiceImageTooLarge,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionImageModeration"
            );
        }
        $endpoint = "https://rekognition.$this->region.amazonaws.com";
        $uri = '/';
        $query = [];

        $payload = $request->getJSONRequestBody();

        // Rekognition and AWS specific headers
        $headers = [
            'Content-Type' => 'application/x-amz-json-1.1',
            'X-Amz-Target' => 'RekognitionService.DetectModerationLabels'
        ];
        $method = "POST";

        // Sign the request
        $signedHeaders = $this->awsAuthService->signRequest(
            $method,
            $uri,
            $query,
            $headers,
            $payload
        );


        $response = Http::withHeaders($signedHeaders)
            -> withBody($payload, 'application/x-amz-json-1.1')
            -> post($endpoint);
        if (
            $response->failed()
            && $response->json('Code') != 'InvalidImageFormatException'
        ) {
            $message = "Rekognition Image Moderation request failed";
            Log::alert($message, (array)$response->json());
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::RekognitionUnavailable,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionImageModeration"
            );
        } else if (
            $response->failed()
            && $response->json('Code') == 'InvalidImageFormatException'
        ) {
            $message = "Rekognition invalid image format";
            Log::alert($message . $response->body(), (array)$response);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::ModerationServiceInvalidFormat,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionFacialDetectionAgeRange"
            );
        }
        Log::debug('Rekognition response: ',$response->json());
        return new ModerationResponse($response->json());
    }

    /**
     * @throws PolyamoryMatchException
     * @throws ConnectionException
     */
    public function getRekognitionFacialDetectionAgeRange(
        RekognitionFacialDetectionAgeRangeRequest $request
    ): RekognitionFacialDetectionAgeRangeResponse {
        $totalBytes = strlen($request->image->bytes);
        if ( $totalBytes >= 5242880) {
            $message = "Rekognition Image Moderation request failed";
            Log::alert($message);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::ModerationServiceImageTooLarge,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionFacialDetectionAgeRange"
            );
        }

        $endpoint = "https://rekognition.$this->region.amazonaws.com";
        $uri = '/';
        $query = [];

        $payload = $request->getJSONRequestBody();

        // Rekognition and AWS specific headers
        $headers = [
            'Content-Type' => 'application/x-amz-json-1.1',
            'X-Amz-Target' => 'RekognitionService.DetectFaces'
        ];
        $method = "POST";

        // Sign the request
        $signedHeaders = $this->awsAuthService->signRequest(
            $method,
            $uri,
            $query,
            $headers,
            $payload
        );



        $response = Http::withHeaders($signedHeaders)
            -> withBody($payload, 'application/x-amz-json-1.1')
            -> post($endpoint);

        if (
            $response->failed()
            && $response->json('Code') != 'InvalidImageFormatException'
        ) {
            $message = "Rekognition Facial Detection request failed";
            Log::alert($message . $response->body(), (array)$response);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::RekognitionUnavailable,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionFacialDetectionAgeRange"
            );
        } else if (
            $response->failed()
            && $response->json('Code') == 'InvalidImageFormatException'
        ) {
            $message = "Rekognition invalid image format";
            Log::alert($message . $response->body(), (array)$response);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::ModerationServiceInvalidFormat,
                message: $message,
                fileName: $this->fileName,
                funcName: "getRekognitionFacialDetectionAgeRange"
            );
        }

        return new RekognitionFacialDetectionAgeRangeResponse(json_decode($response->body(), true));
    }
}
