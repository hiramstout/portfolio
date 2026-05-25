<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs;

use App\Services\Exceptions\PolyamoryMatchException;
use App\Services\Exceptions\PolyamoryMatchExceptionEnum;
use App\Services\ImageModerationService\AWSRekognition\DTOs\Image\Image;

class RekognitionModerationRequest {
    public Image $image;
    public ?float $minConfidence;
    public ?string $projectVersion;

    /**
     * @param Image $image
     * @param float|null $minConfidence // Must be a number >0 && <100
     * @param string|null $projectVersion
     */
    public function __construct(
        Image $image,
        ?float $minConfidence = null,
        ?string $projectVersion = null
    ) {
        $this->image = $image;
        $this->minConfidence = $minConfidence;
        $this->projectVersion = $projectVersion;
    }

    public function getJSONRequestBody(): string {
        $body['Image'] = $this->image->getJSONRequestArray();
        if ($this->minConfidence) {
            $body['MinConfidence'] = $this->minConfidence;
        }
        if ($this->projectVersion) {
            $body['ProjectVersion'] = $this->projectVersion;
        }
        return json_encode($body);
    }
}
