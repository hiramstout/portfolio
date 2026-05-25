<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses\MaleChestCategories;

class MaleChestCategories {
    public float $veryRevealing;
    public float $revealing;
    public float $slightlyRevealing;
    public float $none;

    public function __construct(array $data) {
        $this->veryRevealing = $data['very_revealing'];
        $this->revealing = $data['revealing'];
        $this->slightlyRevealing = $data['slightly_revealing'];
        $this->none = $data['none'];
    }
}
