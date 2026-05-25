<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses\CleavageCategories;

class CleavageCategories {
    public float $veryRevealing;
    public float $revealing;
    public float $none;

    public function __construct(array $data) {
        $this->veryRevealing = $data['very_revealing'];
        $this->revealing = $data['revealing'];
        $this->none = $data['none'];
    }
}
