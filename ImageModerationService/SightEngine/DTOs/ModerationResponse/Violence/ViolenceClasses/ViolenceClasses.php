<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Violence\ViolenceClasses;

class ViolenceClasses {
    public float $physicalViolence;
    public float $firearmThreat;
    public float $combatSport;

    public function __construct(array $data) {
        $this->physicalViolence = $data['physical_violence'];
        $this->firearmThreat = $data['firearm_threat'];
        $this->combatSport = $data['combat_sport'];
    }
}
