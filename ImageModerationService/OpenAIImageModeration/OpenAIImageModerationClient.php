<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationRequest;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ModerationResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OpenAIImageModerationClient
{
    private string $apiKey;
    private string $apiBaseUrl;
    private string $apiEndpoint = 'moderations';
    private string $fileName = 'OpenAIImageModerationClient.php';

    public function __construct() {
        $this->apiKey = config('openai.api_key');
        $this->apiBaseUrl = config('openai.api_base_url');
    }

    /**
     * @throws \Illuminate\Http\Client\ConnectionException
     * @throws \App\Services\Exceptions\PolyamoryMatchException
     */
    public function getModerationRequestResponse(
        ModerationRequest $moderationRequest,
    ): ModerationResponse {

        $result = Http::withHeaders([
            'Authorization' => 'Bearer ' . $this->apiKey,
            'Content-Type' => 'application/json',
        ])->withBody(json_encode(
            $moderationRequest->getModerationRequestJsonArray()
        ))->post(
            $this->apiBaseUrl . $this->apiEndpoint,
        );

        if ($result->failed()) {
            $errMessage = $result->getStatusCode()
                          . $result->getBody()
                          . '. OpenAI Moderation API request failed';
            Log::error($errMessage);
            throw new PolyamoryMatchException(
                exceptionType: PolyamoryMatchExceptionEnum::OpenAIModerationUnavailable,
                message: $errMessage,
                fileName: $this->fileName,
                funcName: 'getModerationRequestResponse'
            );
        }

        return new ModerationResponse(json_decode($result->body(), true));
    }
}
