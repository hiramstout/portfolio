<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\GoreType;

class GoreType {
    public float $animated;
    public float $fake;
    public float $real;

    public function __construct(array $data) {
        $this->animated = $data['animated'];
        $this->fake = $data['fake'];
        $this->real = $data['real'];
    }
}
