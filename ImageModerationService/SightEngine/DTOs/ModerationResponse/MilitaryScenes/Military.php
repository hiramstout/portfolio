<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MilitaryScenes;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MilitaryScenes\MilitaryClasses\MilitaryClasses;

class Military {
    public float           $prob;
    public MilitaryClasses $classes;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->classes = new MilitaryClasses($data['classes']);
    }
}
