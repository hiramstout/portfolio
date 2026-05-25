<?php

namespace App\Services\ImageModerationService\Arachnid\DTOs;

enum MatchTypeEnum: string {
    case exact = 'exact';
    case near = 'near';

    public function label(): string {
        return match ($this) {
            self::exact => 'exact',
            self::near => 'near',
        };
    }
}
