<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection\ContentTypes\ContentTypes;
use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabel;
use ArrayIterator;

/**
 * @extends ArrayIterator<int,ContentTypes>
 */
class ContentTypesIterator extends ArrayIterator {
    public function current(): ContentTypes {
        return parent::current();
    }

    public function offsetGet(mixed $key): ContentTypes {
        return parent::offsetGet($key);
    }
}
