<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Status;
enum StatusEnum: string {
    case success = "success";
    case failure = "failure";
}
