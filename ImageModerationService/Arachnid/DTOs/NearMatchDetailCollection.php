<?php

namespace App\Services\ImageModerationService\Arachnid\DTOs;

use ArrayIterator;
use Countable;
use IteratorAggregate;
use Traversable;

class NearMatchDetailCollection implements IteratorAggregate, Countable
{
    private array $nearMatchDetailItems = [];

    public function __construct(NearMatchDetailItem ...$nearMatchDetailItems) {
        $this->nearMatchDetailItems = $nearMatchDetailItems;
    }

    public static function fromArray(array $data): self {
        $nearMatchDetailItems = [];
        foreach ($data as $itemData) {
            $nearMatchDetailItems[] = NearMatchDetailItem::fromArray($itemData);
        }
        return new self(...$nearMatchDetailItems);
    }

    /**
     * @return NearMatchDetailItem[]
     */
    public function all(): array {
        return $this->nearMatchDetailItems;
    }

    /**
     * @inheritDoc
     */
    public function getIterator(): Traversable
    {
        return new ArrayIterator($this->nearMatchDetailItems);
        // TODO: Implement getIterator() method.
    }

    public function count(): int {
        return count($this->nearMatchDetailItems);
    }

    public function hasNearMatchDetailItems(): bool {
        return $this->count() > 0;
    }
}
