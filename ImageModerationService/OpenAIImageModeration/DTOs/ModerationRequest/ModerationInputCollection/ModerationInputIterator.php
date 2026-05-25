<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ModerationInput;
use ArrayIterator;

class ModerationInputIterator extends ArrayIterator
{
    public function current(): ModerationInput {
        return parent::current();
    }

    public function offsetGet(mixed $key): ModerationInput {
        return parent::offsetGet($key);
    }
}
