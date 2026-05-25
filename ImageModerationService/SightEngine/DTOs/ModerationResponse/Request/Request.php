<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Request;

use DateTime;

class Request {
    public string   $id;
    public DateTime $timestamp;
    public int      $operations;

    public function __construct(array $data) {
        $this->id = $data['id'];
        $this->timestamp = DateTime::createFromTimestamp($data['timestamp']);
        $this->operations = $data['operations'];
    }
}
