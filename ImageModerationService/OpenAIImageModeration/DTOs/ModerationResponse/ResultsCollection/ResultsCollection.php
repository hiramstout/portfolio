<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\Result;
use Countable;
use Illuminate\Contracts\Database\Eloquent\Castable;
use IteratorAggregate;
use Traversable;

class ResultsCollection implements IteratorAggregate, Countable
{
    private array $items;

    public function __construct(array $data) {
        $items = [];
        foreach ($data as $item) {
            $items[] = new Result($item);
        }
        $this->items = $items;
    }

    /**
     * @return Result[]
     */
    public function all(): array {
        return $this->items;
    }

    public function toArray(): array {
        $items = [];
        foreach ($this->items as $item) {
            $items[] = $item->toArray();
        }
        return $items;
    }

    /**
     * @inheritDoc
     */
    public function getIterator(): ResultsIterator {
        return new ResultsIterator($this->items);
    }

    public function count(): int {
        return count($this->items);
    }

    public function hasResults(): bool {
        return count($this->items) > 0;
    }
}
