<?php

namespace App\Services\ImageModerationService\Arachnid\DTOs;

use Illuminate\Support\Facades\Log;
use TypeError;

class NearMatchDetailItem
{
    public function __construct(
        public readonly ScanResultClassificationEnum $classification,
        public readonly string $sha1Base32,
        public readonly string $sha256Hex,
        public readonly \DateTime $timestamp,
    ){}

    public static function fromArray(array $data): self {
        $scanResultClassification = ScanResultClassificationEnum::tryFrom($data['classification']);

        // TODO: Throw new Exception
        if (!$scanResultClassification) {
            Log::error("NearMatchDetailItem Error: Classification Not Found among enum options: {$data['classification']}");
        }

        $timestamp = new \DateTime();

        try {
            $timestamp->setTimestamp($data['timestamp']);
            $timestamp->setTimezone(new \DateTimeZone('UTC'));
        } catch (TypeError $e) {
            // Invalid data type provided
            Log::error('Invalid data type provided. Should be a double number (json) unix timestamp. NearMatchDetailItem Error: ' . $e->getMessage());
        } catch (\DateRangeError $e) {
            Log::error('Invalid date range provided, out of system range NearMatchDetailItem Error: ' . $e->getMessage());
        } catch (\Exception $e) {
            Log::error('DateTime casting error: ' . $e->getMessage());
        }

        return new self(
            classification: $scanResultClassification,
            sha1Base32: $data['sha1_base32'],
            sha256Hex: $data['sha256_hex'],
            timestamp: $timestamp
        );
    }
}
