<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\Image;

use App\Services\ImageModerationService\AWSRekognition\DTOs\Image\S3BucketObject\S3BucketObject;

class Image {
    public ?string $bytes; // When compiling JSON request, must not have quotations surrounding binary data (no "")
    public ?S3BucketObject $s3BucketObject;

    public function __construct(
        ?string $bytes = null,
        ?S3BucketObject $s3BucketObject = null,
    ) {
        $this->bytes = $bytes;
        $this->s3BucketObject = $s3BucketObject;
    }

    public function getJSONRequestArray(): array {
        $requestArray = [];
        if ($this->bytes !== null) {
            $requestArray["Bytes"] = $this->bytes;
        }
        if ($this->s3BucketObject !== null) {
            $requestArray["S3Object"] = $this->s3BucketObject->getJSONRequestArray();
        }
        return $requestArray;
    }
}
