<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\Categories\Categories;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\CategoryAppliedInputTypes\CategoryAppliedInputTypes;
use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\CategoryScores\CategoryScores;

class Result
{
    public bool $flagged;
    public Categories $categories;
    public CategoryAppliedInputTypes $categoryAppliedInputTypes;
    public CategoryScores $categoryScores;

    public function __construct(array $data) {
        $this->flagged = $data['flagged'];
        $this->categories = new Categories($data['categories']);
        $this->categoryAppliedInputTypes = new CategoryAppliedInputTypes($data['category_applied_input_types']);
        $this->categoryScores = new CategoryScores($data['category_scores']);
    }

    public function toArray(): array {
        return [
            'flagged' => $this->flagged,
            'categories' => (array)$this->categories,
            'categoryAppliedInputTypes' => $this->categoryAppliedInputTypes->toArray(),
            'categoryScores' => (array)$this->categoryScores,
        ];
    }
}
