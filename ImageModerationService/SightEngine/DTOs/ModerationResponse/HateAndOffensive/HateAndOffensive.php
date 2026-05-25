<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\HateAndOffensive;

class HateAndOffensive {
    public float $nazi;
    public float $asianSwastika;
    public float $confederate;
    public float $supremacist;
    public float $terrorist;
    public float $middleFinger;
    public function __construct(array $data) {
        $this->nazi = $data['nazi'];
        $this->asianSwastika = $data['asian_swastika'];
        $this->confederate = $data['confederate'];
        $this->supremacist = $data['supremacist'];
        $this->terrorist = $data['terrorist'];
        $this->middleFinger = $data['middle_finger'];
    }
}
