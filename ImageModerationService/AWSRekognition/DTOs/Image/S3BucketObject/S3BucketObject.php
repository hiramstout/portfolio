<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\Image\S3BucketObject;

class S3BucketObject {
    public string $bucket; // Field name "Bucket"
    public string $name;  // Field name "Name"
    public string $version; // Field name "Version"

    public function __construct(
        string $bucket,
        string $name,
        string $version,
    ) {
        $this->bucket = $bucket;
        $this->name = $name;
        $this->version = $version;
    }

    public function getJSONRequestArray(): array {
        return [
            'Bucket' => $this->bucket,
            'Name' => $this->name,
            'Version' => $this->version,
        ];
    }
}
