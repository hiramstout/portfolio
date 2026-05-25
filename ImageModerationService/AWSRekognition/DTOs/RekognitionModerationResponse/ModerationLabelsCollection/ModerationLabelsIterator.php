<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabel;
use ArrayIterator;
use Iterator;

/**
 * @extends ArrayIterator<int,ModerationLabel>
 */
class ModerationLabelsIterator extends ArrayIterator implements Iterator {
    public function current(): ModerationLabel {
        return parent::current();
    }

    public function offsetGet(mixed $key): ModerationLabel {
        return parent::offsetGet($key);
    }
}
