<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetails;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetails\AgeRange\AgeRange;

class FaceDetail {
    /**
     * @var AgeRange $ageRange Predicted age range for face
     */
    public AgeRange $ageRange;

    public function __construct(
        array $data
    ) {
        $this->ageRange = new AgeRange($data['AgeRange']);
    }
}
