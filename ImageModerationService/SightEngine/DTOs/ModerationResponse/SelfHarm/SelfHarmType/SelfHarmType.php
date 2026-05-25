<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\SelfHarm\SelfHarmType;

class SelfHarmType {
    public float $real;
    public float $fake;
    public float $animated;

    public function __construct(array $data) {
        $this->real = $data['real'];
        $this->fake = $data['fake'];
        $this->animated = $data['animated'];
    }
}
