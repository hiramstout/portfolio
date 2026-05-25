<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MedicalDrugs\MedicalClasses;

class MedicalClasses {
    public float $cannabis;
    public float $cannabisLogoOnly;
    public float $cannabisPlant;
    public float $cannabisDrug;
    public float $recreationalDrugsNotCannabis;

    public function __construct(array $data) {
        $this->cannabis = $data['cannabis'];
        $this->cannabisLogoOnly = $data['cannabis_logo_only'];
        $this->cannabisPlant = $data['cannabis_plant'];
        $this->cannabisDrug = $data['cannabis_drug'];
        $this->recreationalDrugsNotCannabis = $data['recreational_drugs_not_cannabis'];
    }
}
