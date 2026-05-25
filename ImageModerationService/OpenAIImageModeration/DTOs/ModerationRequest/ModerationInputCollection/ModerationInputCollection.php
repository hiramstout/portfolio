<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationRequest\ModerationInputCollection\ModerationInput\ModerationInput;
use Traversable;

class ModerationInputCollection implements \IteratorAggregate, \Countable
{
    private array $items;

    public function __construct(ModerationInput ...$moderationInput) {
        $this->items = $moderationInput;
    }

    public function getIterator(): ModerationInputIterator {
        return new ModerationInputIterator($this->items);
    }

    public function count(): int {
        return count($this->items);
    }

    public function getAll(): array {
        return $this->items;
    }

    public function getJsonRequestArrays() {
        $items = [];
        foreach($this->items as $item) {
            $items[] = $item->getModerationInputRequestArray();
        }
        return $items;
    }
}
