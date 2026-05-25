<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MedicalDrugs;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MedicalDrugs\MedicalClasses\MedicalClasses;

class MedicalDrugs {
    public float $prob;
    public MedicalClasses $medicalClasses;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->medicalClasses = new MedicalClasses($data['classes']);
    }
}
