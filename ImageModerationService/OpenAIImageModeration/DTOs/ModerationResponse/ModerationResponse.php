<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse;

use App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\ResultsCollection;

class ModerationResponse
{
    public string $id;
    public string $model;
    public ResultsCollection $results;

    public function __construct(array $data) {
        $this->id = $data['id'];
        $this->model = $data['model'];
        $this->results = new ResultsCollection($data['results']);
    }
}
