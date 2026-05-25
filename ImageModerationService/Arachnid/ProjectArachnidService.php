<?php

namespace App\Services\ImageModerationService\Arachnid;

use App\Services\ImageModerationService\Arachnid\DTOs\ScanMediaResponse;
use Exception;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;

class ProjectArachnidService
{
    protected string $baseUrl;
    protected string $apiUser;
    protected string $apiKey;

    public function __construct() {
        $this->apiUser = config('arachnid.apiUserName');
        $this->apiKey = config('arachnid.apiPassword');
        $this->baseUrl = config('arachnid.baseUrl');
    }


    /**
     * @throws Exception
     */
    public function scanMediaFile(UploadedFile $picture): ScanMediaResponse {

        $response = Http::withBody(
            $picture->getContent(), $picture -> getMimeType()
        ) -> acceptJson() -> withBasicAuth(
            $this->apiUser, $this->apiKey
        )->post(
            $this->baseUrl . 'media'
        );
        if ($response->successful()) {
            return ScanMediaResponse::fromArray($response->json());
        }

        \Log::error('Arachnid API request failed: ',[
            'status' => $response->status(),
            'endpoint' => 'image',
            'baseurl' => $this->baseUrl,
            'response' => $response->body(),
        ]);

        throw new Exception($response->body());
    }
}
