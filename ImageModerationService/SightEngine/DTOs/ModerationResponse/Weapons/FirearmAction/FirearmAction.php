<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\FirearmAction;

class FirearmAction {
    public float $animated;
    public function __construct(array $data) {
        $this->animated = $data["animated"];
    }
}
