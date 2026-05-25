<?php

namespace App\Services\ImageModerationService\CloudVisionAI\DTOs;

use Illuminate\Http\UploadedFile;

class SafeSearchModerationRequest
{
    public UploadedFile $file;
    public function __construct(UploadedFile $file) {
        $this->file = $file;
    }

    public function getJsonRequestBody(): string {
        return json_encode([
            "requests" => [
                "image" => [
                    "content" => base64_encode($this->file->getContent())
                ],
                "features" => [
                    "type" => "SAFE_SEARCH_DETECTION"
                ]
            ]
        ]);
    }
}
