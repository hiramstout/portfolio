<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ImageUrl\ImageUrl;

class ModerationInput
{
    private string $type = "image_url";
    public ImageUrl $imageUrl;

    public function __construct(ImageUrl $imageUrl) {
        $this->imageUrl = $imageUrl;
    }

    public function getModerationInputRequestArray(): array {
        return [
            "type" => $this->type,
            "image_url" => $this->imageUrl->getImageUrlRequestArray(),
        ];
    }
}
