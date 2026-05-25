<?php

namespace App\Services\ImageModerationService\Arachnid\DTOs;

use Illuminate\Support\Facades\Log;

class ScanMediaResponse
{
    public function __construct(
        public readonly ScanResultClassificationEnum $classification,
        public readonly ?MatchTypeEnum $matchType,
        public readonly NearMatchDetailCollection $nearMatchDetails,
        public readonly string $sha1_base32,
        public readonly string $sha256_hex,
        public readonly int $size_bytes
    ) {}

    public static function fromArray(array $data): self {

        // TODO: Throw new Exception
        if (!ScanResultClassificationEnum::tryFrom($data['classification'])) {
            Log::error("Classification Not Found among enum options: {$data['classification']}");
        }
        return new self(
            classification: ScanResultClassificationEnum::from($data['classification']),
            matchType: MatchTypeEnum::tryFrom($data['match_type']),
            nearMatchDetails: NearMatchDetailCollection::fromArray($data['near_match_details']),
            sha1_base32: $data['sha1_base32'],
            sha256_hex: $data['sha256_hex'],
            size_bytes: $data['size_bytes'],
        );
    }

}
