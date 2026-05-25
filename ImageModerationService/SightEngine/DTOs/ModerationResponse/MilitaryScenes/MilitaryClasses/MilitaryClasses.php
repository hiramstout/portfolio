<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MilitaryScenes\MilitaryClasses;

class MilitaryClasses {
    public float $militaryEquipment;
    public float $militaryPersonnel;
    public float $militaryProfilePhoto;
    public function __construct(array $data) {
        $this->militaryEquipment = $data['military_equipment'];
        $this->militaryPersonnel = $data['military_personnel'];
        $this->militaryProfilePhoto = $data['military_profile_photo'];
    }
}
