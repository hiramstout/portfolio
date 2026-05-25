<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetails\AgeRange;

class AgeRange
{
    public int $high;
    public int $low;

    public function __construct(array $data) {
        $this->high = $data['High'];
        $this->low = $data['Low'];
    }
}
