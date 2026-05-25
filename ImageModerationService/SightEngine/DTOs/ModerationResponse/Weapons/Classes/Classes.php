<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\Classes;

class Classes {
    public float $firearm;
    public float $firearmGesture;
    public float $firearmToy;
    public float $knife;
    public function __construct(array $data) {
        $this->firearm = $data["firearm"];
        $this->firearmGesture = $data["firearm_gesture"];
        $this->firearmToy = $data["firearm_toy"];
        $this->knife = $data["knife"];
    }
}
