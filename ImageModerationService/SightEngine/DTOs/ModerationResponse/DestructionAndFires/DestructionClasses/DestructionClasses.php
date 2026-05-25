<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\DestructionAndFires\DestructionClasses;

class DestructionClasses {
    public float $buildingMajorDamage;
    public float $buildingMinorDamage;
    public float $buildingOnFire;
    public float $buildingBurned;
    public float $vehicleMajorDamage;
    public float $vehicleMinorDamage;
    public float $vehicleOnFire;
    public float $vehicleBurned;
    public float $wildfire;
    public float $unsafeFire;
    public float $violentProtest;

    public function __construct(array $data) {
        $this->buildingMajorDamage = $data['building_major_damage'];
        $this->buildingMinorDamage = $data['building_minor_damage'];
        $this->buildingOnFire = $data['building_on_fire'];
        $this->buildingBurned = $data['building_burned'];
        $this->vehicleMajorDamage = $data['vehicle_major_damage'];
        $this->vehicleMinorDamage = $data['vehicle_minor_damage'];
        $this->vehicleOnFire = $data['vehicle_on_fire'];
        $this->vehicleBurned = $data['vehicle_burned'];
        $this->wildfire = $data['wildfire'];
        $this->unsafeFire = $data['unsafe_fire'];
        $this->violentProtest = $data['violent_protest'];
    }
}
