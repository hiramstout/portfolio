<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\DestructionAndFires;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\DestructionAndFires\DestructionClasses\DestructionClasses;

class Destruction {
    public float              $prob;
    public DestructionClasses $classes;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->classes = new DestructionClasses($data['classes']);
    }
}
