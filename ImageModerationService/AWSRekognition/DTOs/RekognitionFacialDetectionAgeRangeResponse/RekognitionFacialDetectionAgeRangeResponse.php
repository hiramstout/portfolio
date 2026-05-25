<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetailsCollection;

class RekognitionFacialDetectionAgeRangeResponse {
    public FaceDetailsCollection $faceDetails;

    public function __construct(array $data) {
        $this->faceDetails = new FaceDetailsCollection($data['FaceDetails']);
    }
}
