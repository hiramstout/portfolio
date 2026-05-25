<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\GoreClasses;

class GoreClasses {
    public float $veryBloody;
    public float $slightlyBloody;
    public float $bodyOrgan;
    public float $seriousInjury;
    public float $superficialInjury;
    public float $corpse;
    public float $skull;
    public float $unconscious;
    public float $bodyWaste;
    public float $other;

    public function __construct(array $data) {
        $this->veryBloody = $data['very_bloody'];
        $this->slightlyBloody = $data['slightly_bloody'];
        $this->bodyOrgan = $data['body_organ'];
        $this->seriousInjury = $data['serious_injury'];
        $this->superficialInjury = $data['superficial_injury'];
        $this->corpse = $data['corpse'];
        $this->skull = $data['skull'];
        $this->unconscious = $data['unconscious'];
        $this->bodyWaste = $data['body_waste'];
        $this->other = $data['other'];
    }
}
