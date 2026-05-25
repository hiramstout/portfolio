<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInputCollection;

class ModerationRequest
{
    private string $model = "omni-moderation-latest";
    public ModerationInputCollection $input;

    public function __construct(ModerationInputCollection $input) {
        $this->input = $input;
    }

    public function getModerationRequestJsonArray(): array {

        return [
            "model" => $this->model,
            "input" => $this->input->getJsonRequestArrays()
        ];
    }
}
