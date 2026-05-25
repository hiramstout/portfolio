<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\GoreClasses\GoreClasses;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\Context\Context;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\FirearmAction\FirearmAction;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\FirearmType\FirearmType;

class Weapon {
    public GoreClasses   $classes;
    public FirearmAction $firearmAction;
    public FirearmType $firearmType;

    public function __construct(array $data) {
        $this->classes = new GoreClasses($data['classes']);
        $this->firearmAction = new FirearmAction($data['firearm_action']);
        $this->firearmType = new FirearmType($data['firearm_type']);
    }
}
