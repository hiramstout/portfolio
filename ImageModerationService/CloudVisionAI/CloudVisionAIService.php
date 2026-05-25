<?php

namespace App\Services\ImageModerationService\CloudVisionAI;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\CloudVisionAI\DTOs\SafeSearchModerationRequest;
use App\Services\ImageModerationService\CloudVisionAI\DTOs\SafeSearchModerationResponse;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Log;

class CloudVisionAIService
{
    protected string $clientEmail;
    protected string $serviceAccountPrivateKey;
    protected string $accessToken;
    protected string $scopes = 'https://www.googleapis.com/auth/cloud-vision';
    protected string $fileName = 'app/Services/ImageModerationService/GCPCloudVision/CloudVisionAIService.php';
    protected string $userProject;
    protected string $apiBaseURL = 'https://vision.googleapis.com/v1/';
    protected string $imageAnnotateEndpoint = 'images:annotate';
    public function __construct() {
        $this->serviceAccountPrivateKey = config('cloud-vision-ai.serviceAccountKey.private_key');
        $this->clientEmail = config('cloud-vision-ai.serviceAccountKey.client_email');
        $this->userProject = config('cloud-vision-ai.serviceAccountKey.project_id');
    }

    protected function _base64UrlEncode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * @throws PolyamoryMatchException
     */
    protected function _generateJWT(): string {
        $jwtHeader = json_encode([
            'typ' => 'JWT',
            'alg' => 'RS256'
        ]);

        $now = time();
        $payload = json_encode([
            'iat' => $now,
            'iss' => $this->clientEmail,
            'scope' => $this->scopes,
            'exp' => $now + 3600,
            'aud' => 'https://oauth2.googleapis.com/token',
        ]);

        $base64UrlHeader = $this->_base64UrlEncode($jwtHeader);
        $base64UrlPayload = $this->_base64UrlEncode($payload);

        $signatureInput = $base64UrlHeader . "." . $base64UrlPayload;

        $signature = '';
        $success = openssl_sign(
            $signatureInput,
            $signature,
            $this->serviceAccountPrivateKey,
            OPENSSL_ALGO_SHA256
        );

        if (!$success) {
            $errorMessage = 'Cloud Vision AI Service Account JWT authorization failed';
            Log::error($errorMessage);
            throw new PolyamoryMatchException(
                PolyamoryMatchExceptionEnum::ModerationAPIAuthenticationFailed,
                $errorMessage,
                $this->fileName,
                '_generateAccessToken'
            );
        }

        $base64UrlSignature = $this->_base64UrlEncode($signature);

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    /**
     * @throws PolyamoryMatchException
     * @throws ConnectionException
     */
    protected function _fetchNewAccessToken(): object {
        $jwt = $this->_generateJWT();

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]);

        if ($response->failed()) {
            $errorMessage = 'Cloud Vision AI access token generation failed';
            Log::error($errorMessage);
            throw new PolyamoryMatchException(
                PolyamoryMatchExceptionEnum::ModerationAPIAuthenticationFailed,
                $errorMessage,
                $this->fileName,
                '_generateJWT'
            );
        }

        $tokenData = $response->object();

        if (!isset($tokenData->access_token)) {
            $errorMessage = 'Access token not found in response';
            Log::error($errorMessage);
            throw new PolyamoryMatchException(
                PolyamoryMatchExceptionEnum::ModerationAPIAuthenticationFailed,
                $errorMessage,
                $this->fileName,
                '_generateJWT'
            );
        }

        return $tokenData;
    }

    /**
     * @throws PolyamoryMatchException
     * @throws ConnectionException
     */
    protected function _getAccessToken(): string {

        // Uses a key that is unique to the specific service account key
        $cacheKey = 'google_access_token_' . md5($this->clientEmail);

        // Check if there is already a key in the cache
        if (Cache::has($cacheKey)) {
            return Cache::get($cacheKey);
        }

        // Fetch a fresh token if not
        $tokenData = $this->_fetchNewAccessToken();

        // Store in cache with a buffer of 60 seconds to be safe
        $ttl = $tokenData->expires_in - 60;
        Cache::put($cacheKey, $tokenData->access_token, $ttl);

        return $tokenData->access_token;
    }

    /**
     * @throws PolyamoryMatchException
     * @throws ConnectionException
     */
    public function getSafeSearchAnnotationForImage(UploadedFile $picture): SafeSearchModerationResponse {
        $requestBody = new SafeSearchModerationRequest($picture)
            ->getJsonRequestBody();
        $response = Http::withToken(
            $this->_getAccessToken()
        )->withHeaders([
            'Content-AiDetectionType' => 'application/json; charset=utf-8',
            'x-goog-user-project' => $this->userProject,
        ])->withBody(
            $requestBody
        )->post(
            $this->apiBaseURL . $this->imageAnnotateEndpoint
        );

        if ($response->failed()) {
            $errorMessage = 'Cloud Vision AI SafeSearch annotation API request failed. '
                . 'Response Body: ' . json_decode($response->body())
                . 'Response Code: ' . $response->status();
            Log::error($errorMessage);

            /* TODO: Build helper function within the exception class itself to take
             *       failed API requests and returns an exception
             */
            throw new PolyamoryMatchException(
                PolyamoryMatchExceptionEnum::GCPCloudVisionUnavailable,
                $errorMessage,
                $this->fileName,
                'getSafeSearchAnnotationForImage'
            );
        }

        return new SafeSearchModerationResponse($response->body());
    }
}
