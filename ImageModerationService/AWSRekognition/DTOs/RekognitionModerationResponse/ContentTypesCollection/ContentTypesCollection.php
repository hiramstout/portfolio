<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ContentTypesCollection\ContentTypes\ContentTypes;
use Countable;
use IteratorAggregate;

class ContentTypesCollection implements IteratorAggregate, Countable{
    private array $items = [];

    public function __construct(array $data) {
        $items = [];
        foreach ($data as $itemData) {
            $items[] = new ContentTypes($itemData);
        }
        $this->items = $items;
    }

    /**
     * @return ContentTypes[]
     */
    public function all(): array {
        return $this->items;
    }

    public function getIterator(): ContentTypesIterator {
        return new ContentTypesIterator($this->items);
    }

    public function count(): int {
        return count($this->items);
    }

    public function hasContentTypes(): bool {
        return $this->count() > 0;
    }
}
