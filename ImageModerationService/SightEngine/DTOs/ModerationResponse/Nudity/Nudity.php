<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\Context\Context;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses\SuggestiveClasses;

class Nudity {
    public float $sexualActivity;
    public float $sexualDisplay;
    public float $erotica;
    public float $verySuggestive;
    public float $suggestive;
    public float $mildlySuggestive;
    public float $none;

    public Context $context;
    public SuggestiveClasses $suggestiveClasses;

    public function __construct(array $data) {
        $this->sexualActivity = $data['sexual_activity'];
        $this->sexualDisplay = $data['sexual_display'];
        $this->erotica = $data['erotica'];
        $this->verySuggestive = $data['very_suggestive'];
        $this->suggestive = $data['suggestive'];
        $this->mildlySuggestive = $data['mildly_suggestive'];
        $this->none = $data['none'];
        $this->context = new Context($data['context']);
        $this->suggestiveClasses = new SuggestiveClasses($data['suggestive_classes']);
    }
}
