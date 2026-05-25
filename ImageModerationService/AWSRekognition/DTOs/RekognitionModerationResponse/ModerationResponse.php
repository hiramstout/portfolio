<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse;


use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection\ContentTypesCollection;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ModerationLabelsCollection;

class ModerationResponse {
    public ContentTypesCollection $contentTypes;
    public ModerationLabelsCollection $moderationLabelsCollection;
    public string $moderationModelVersion;
    public ?string $projectVersion;

    public function __construct(
        array $data
    ) {
        $this->contentTypes = new ContentTypesCollection($data['ContentTypes']);
        $this->moderationLabelsCollection = new ModerationLabelsCollection($data['ModerationLabels']);
        $this->moderationModelVersion = $data['ModerationModelVersion'];
        if (array_key_exists('ProjectVersion', $data)) {
            $this->projectVersion = $data['ProjectVersion'];
        } else {
            $this->projectVersion = null;
        }
    }
}
