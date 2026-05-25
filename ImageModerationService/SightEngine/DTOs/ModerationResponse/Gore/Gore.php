<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\GoreClasses\GoreClasses;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\GoreType\GoreType;

class Gore {
    public float       $prob;
    public GoreClasses $classes;
    public GoreType    $type;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->classes = new GoreClasses($data['classes']);
        $this->type = new GoreType($data['type']);
    }
}
