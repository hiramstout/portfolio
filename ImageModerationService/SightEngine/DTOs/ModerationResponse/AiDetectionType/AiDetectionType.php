<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\AiDetectionType;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\AiDetectionType\AiGenerators\AiGenerators;

class AiDetectionType {
    public float $aiGenerated;
    public ?AiGenerators $aiGenerators;

    public function __construct(array $data) {
        $this->aiGenerated = $data['ai_generated'];
        if (isset($data['ai_generators'])) {
            $this->aiGenerators = new AiGenerators($data['ai_generators']);
        }
    }
}
