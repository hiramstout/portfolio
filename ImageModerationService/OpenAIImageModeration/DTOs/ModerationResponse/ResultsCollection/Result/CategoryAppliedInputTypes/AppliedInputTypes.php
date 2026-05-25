<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\CategoryAppliedInputTypes;

class AppliedInputTypes
{
    public bool $image;
    public bool $text;

    public function __construct(array $data) {
        $this->image = false;
        $this->text = false;
        foreach ($data as $value) {
            if ($value == "image") {
                $this->image = true;
            } else if ($value == "text") {
                $this->text = true;
            }
        }
    }

    public function toArray(): array {
        return [
            "image" => $this->image,
            "text" => $this->text,
        ];
    }
}
