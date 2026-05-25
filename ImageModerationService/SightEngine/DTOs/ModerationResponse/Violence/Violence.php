<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Violence;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Violence\ViolenceClasses\ViolenceClasses;

class Violence {
    public float $prob;
    public ViolenceClasses $classes;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->classes = new ViolenceClasses($data['classes']);
    }
}
