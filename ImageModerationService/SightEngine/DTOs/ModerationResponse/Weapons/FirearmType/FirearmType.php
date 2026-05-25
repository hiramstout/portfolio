<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\FirearmType;

class FirearmType {
    public float $aimingThreat;
    public float $aimingCamera;
    public float $aimingSafe;
    public float $inHandNotAiming;
    public float $wornNotInHand;
    public float $notWorn;

    public function __construct(array $data) {
        $this->aimingThreat = $data["aiming_threat"];
        $this->aimingCamera = $data["aiming_camera"];
        $this->aimingSafe = $data["aiming_safe"];
        $this->inHandNotAiming = $data["in_hand_not_aiming"];
        $this->wornNotInHand = $data["worn_not_in_hand"];
        $this->notWorn = $data["not_worn"];
    }

}
