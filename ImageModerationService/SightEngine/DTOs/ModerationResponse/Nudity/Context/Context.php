<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\Context;

class Context {
    public float $seaLakePool;
    public float $outdoorOther;
    public float $indoorOther;

    public function __construct(array $data) {
        $this->seaLakePool = $data['sea_lake_pool'];
        $this->outdoorOther = $data['outdoor_other'];
        $this->indoorOther = $data['indoor_other'];
    }
}
