<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs;

use App\Services\ImageModerationService\AWSRekognition\DTOs\Image\Image;

class RekognitionFacialDetectionAgeRangeRequest{
    private array $attributes = ['AGE_RANGE'];
    public Image $image;

    public function __construct(Image $image){
        $this->image = $image;
    }

    public function getJSONRequestBody(): string {
        return json_encode([
            "Attributes" => $this->attributes,
            "Image" => $this->image->getJSONRequestArray()
        ]);
    }
}
