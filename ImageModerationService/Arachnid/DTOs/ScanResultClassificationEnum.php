<?php

namespace App\Services\ImageModerationService\Arachnid\DTOs;

enum ScanResultClassificationEnum: string
{
    case CSAM = 'csam';
    case HarmfulAbusiveMaterial = 'harmful-abusive-material';
    case Test = 'test';
    case NoKnownMatch = 'no-known-match';

    public function label(): string {
        return match ($this) {
            self::CSAM => 'CSAM detected',
            self::HarmfulAbusiveMaterial => 'Harmful Abusive Material',
            self::Test => 'Test result',
            self::NoKnownMatch => 'Safe: No known matching CSAM detected',
        };
    }
}
