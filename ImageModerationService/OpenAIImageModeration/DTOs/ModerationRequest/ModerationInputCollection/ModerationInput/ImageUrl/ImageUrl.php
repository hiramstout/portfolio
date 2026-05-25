<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ImageUrl;


use Illuminate\Http\UploadedFile;

class ImageUrl
{
    public UploadedFile $file;
    private string $imageUrl;

    public function __construct(UploadedFile $file) {
        $this->file = $file;
        $this->imageUrl = "data:{$file->getMimeType()};base64," . base64_encode($file->getContent());
    }

    public function getImageUrlRequestArray(): array {
        return [
            "url" => $this->imageUrl,
        ];
    }
}
