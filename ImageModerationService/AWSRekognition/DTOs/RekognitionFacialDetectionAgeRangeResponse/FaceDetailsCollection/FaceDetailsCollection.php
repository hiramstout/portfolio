<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionFacialDetectionAgeRangeResponse\FaceDetailsCollection\FaceDetails\FaceDetail;
use Countable;
use IteratorAggregate;
use Traversable;

class FaceDetailsCollection implements IteratorAggregate, Countable
{
    private array $items = [];

    public function __construct(array $data) {
        $items = [];
        foreach ($data as $itemData) {
            $items[] = new FaceDetail($itemData);
        }
        $this->items = $items;
    }

    /**
     * @return FaceDetail[]
     */
    public function all(): array {
        return $this->items;
    }

    /**
     * @inheritDoc
     */
    public function getIterator(): FaceDetailsIterator {
        return new FaceDetailsIterator($this->items);
    }

    public function count(): int {
        return count($this->items);
    }

    public function hasFaceDetails(): bool {
        return count($this->items) > 0;
    }
}
