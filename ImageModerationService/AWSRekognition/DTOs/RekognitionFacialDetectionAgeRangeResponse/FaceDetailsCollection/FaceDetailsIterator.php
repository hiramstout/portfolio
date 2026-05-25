<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetails\FaceDetail;
use ArrayIterator;

class FaceDetailsIterator extends ArrayIterator {
    public function current(): FaceDetail {
        return parent::current();
    }

    public function offsetGet(mixed $key): FaceDetail  {
        return parent::offsetGet($key);
    }
}
