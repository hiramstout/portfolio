<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Media;

class Media {
    public string $id;
    public string $uri;

    public function __construct(array $data) {
        $this->id = $data["id"];
        $this->uri = $data["uri"];
    }
}
