<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabel;
use Countable;
use IteratorAggregate;
use Traversable;

class ModerationLabelsCollection implements IteratorAggregate, Countable{
    private array $items = [];

    public function __construct(array $data) {
        $items = [];
        foreach ($data as $itemData) {
            $items[] = new ModerationLabel($itemData);
        }
        $this->items = $items;
    }

    /**
     * @return ModerationLabel[]
     */
    public function all(): array {
        return $this->items;
    }

    public function getIterator(): ModerationLabelsIterator {
        return new ModerationLabelsIterator($this->items);
    }

    public function count(): int {
        return count($this->items);
    }

    public function hasContentTypes(): bool {
        return $this->count() > 0;
    }
}
