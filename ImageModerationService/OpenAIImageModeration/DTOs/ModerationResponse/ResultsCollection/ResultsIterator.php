<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\Result;
use ArrayIterator;

class ResultsIterator extends ArrayIterator
{
    public function current(): Result {
        return parent::current();
    }

    public function offsetGet(mixed $key): Result {
        return parent::offsetGet($key);
    }
}
