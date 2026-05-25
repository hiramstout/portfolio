<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MoneyAndCash;

class MoneyAndCash {
    public float $prob;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
    }
}
