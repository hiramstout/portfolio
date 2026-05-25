<?php

namespace App\Services\ImageModerationService\SightEngine;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\ModerationResponse;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SightEngineApiClient {
    private string $apiUser;
    private string $apiSecret;
    private string $apiUrl;
    private string $fileName = 'SightEngineApiClient.php';

    public function __construct() {
        $this->apiUser = config('sight-engine.api_user');
        $this->apiSecret = config('sight-engine.api_secret');
        $this->apiUrl = config('sight-engine.api_url');
    }

    /**
     * @throws \Illuminate\Http\Client\ConnectionException
     * @throws \App\Services\Exceptions\PolyamoryMatchException
     */
    public function getImageModerationResponse(
        UploadedFile $file,
    ): ModerationResponse {
        $result = Http::attach(
            "media",
            $file->getContent(),
            $file->getClientOriginalName()
        )->post(
            $this->apiUrl,
            [
                "models" => Models::aiDetection
//                            . ',' . Models::gore
//                            . ',' . Models::weapon
//                            . ',' . Models::destruction
//                            . ',' . Models::nudity
//                            . ',' . Models::hateAndOffensive
//                            . ',' . Models::money
//                            . ',' . Models::recreationalDrug
//                            . ',' . Models::medicalDrugs
//                            . ',' . Models::selfHarm
//                            . ',' . Models::violence
//                            . ',' . Models::gambling
                            . ',' . Models::military,
                'api_user' => $this->apiUser,
                'api_secret' => $this->apiSecret,
            ]
        );
        if ($result->failed()) {
            $errMessage = "Sight Engine API Error. Code: {$result->status()}. Response: {$result->body()}";
            Log::error($errMessage);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::SightEngineUnavailable,
                message: $errMessage,
                fileName: $this->fileName,
                funcName: 'getImageModerationResponse'
            );
        }

        return new ModerationResponse(json_decode($result->body(),true));
    }
}
