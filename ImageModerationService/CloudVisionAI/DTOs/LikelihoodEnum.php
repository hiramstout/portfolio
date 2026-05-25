<?php

namespace App\Services\ImageModerationService\CloudVisionAI\DTOs;
enum LikelihoodEnum: string
{
    case unknown = 'UNKNOWN';
    case veryUnlikely = 'VERY_UNLIKELY';
    case unlikely = 'UNLIKELY';
    case possible = 'POSSIBLE';
    case likely = 'LIKELY';
    case veryLikely = 'VERY_LIKELY';

    public function label(): string {
        return match ($this) {
            self::unknown => 'Unknown',
            self::veryUnlikely => 'Very Unlikely',
            self::unlikely => 'Unlikely',
            self::possible => 'Possible',
            self::likely => 'Likely',
            self::veryLikely => 'Very Likely',
        };
    }
    public function severity(): int {
        return match ($this) {
            self::unknown => 0,
            self::veryUnlikely => 1,
            self::unlikely => 2,
            self::possible => 3,
            self::likely => 4,
            self::veryLikely => 5,
        };
    }
}
