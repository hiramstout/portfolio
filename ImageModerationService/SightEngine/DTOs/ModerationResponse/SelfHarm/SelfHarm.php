<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\SelfHarm;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\SelfHarm\SelfHarmType\SelfHarmType;

class SelfHarm {
    public float $prob;
    public SelfHarmType $type;
    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->type = new SelfHarmType($data['type']);
    }
}
