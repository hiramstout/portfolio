<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection\ContentTypes;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabelEnum;

class ContentTypes {
    public int $confidence; // JSON field name "Confidence"
    public ModerationLabelEnum $name; // JSON field name "Name"

    public function __construct(
        array $data
    ) {
        $this->confidence = $data['Confidence'];
        $this->name = ModerationLabelEnum::tryFrom($data['Name']) ?? ModerationLabelEnum::na;
    }
}
