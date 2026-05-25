<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\RecreationalDrugs;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\RecreationalDrugs\RecreationalClasses\RecreationalClasses;

class RecreationalDrugs {
    public float $prob;
    public RecreationalClasses $recreationalClasses;

    public function __construct(array $data) {
        $this->prob = $data['prob'];
        $this->recreationalClasses = new RecreationalClasses($data['recreational_classes']);
    }
}
