<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\AiDetectionType\AiDetectionType;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\DestructionAndFires\Destruction;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gambling\Gambling;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Gore\Gore;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\HateAndOffensive\HateAndOffensive;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Media\Media;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MedicalDrugs\MedicalDrugs;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MilitaryScenes\Military;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\MoneyAndCash\MoneyAndCash;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\Nudity;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\RecreationalDrugs\RecreationalDrugs;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Request\Request;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\SelfHarm\SelfHarm;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Status\StatusEnum;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Violence\Violence;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Weapons\Weapon;

class ModerationResponse {
    public StatusEnum          $status;
    public Request             $request;
    public Media               $media;
    public AiDetectionType     $aiDetectionType;
    public ?Destruction         $destruction;
    public ?Gambling            $gambling;
    public ?Gore                $gore;
    public ?HateAndOffensive    $hateAndOffensive;
    public ?MedicalDrugs        $medicalDrugs;
    public Military            $military;
    public ?MoneyAndCash        $moneyAndCash;
    public ?Nudity              $nudity;
    public ?RecreationalDrugs   $recreationalDrugs;
    public ?SelfHarm            $selfHarm;
    public ?Violence            $violence;
    public ?Weapon              $weapon;

    public function __construct(array $data) {
        $this->status            = StatusEnum::from($data["status"]);
        $this->request           = new Request($data["request"]);
        $this->media             = new Media($data["media"]);
        $this->aiDetectionType   = new AiDetectionType($data["type"]);
//        $this->destruction       = new Destruction($data["destruction"]);
//        $this->gambling          = new Gambling($data["gambling"]);
//        $this->gore              = new Gore($data["gore"]);
//        $this->hateAndOffensive  = new HateAndOffensive($data["offensive"]);
//        $this->medicalDrugs      = new MedicalDrugs($data["medical"]);
        $this->military          = new Military($data["military"]);
//        $this->moneyAndCash      = new MoneyAndCash($data["money"]);
//        $this->nudity            = new Nudity($data["nudity"]);
//        $this->recreationalDrugs = new RecreationalDrugs($data["recreational_drug"]);
//        $this->selfHarm          = new SelfHarm($data["self-harm"]);
//        $this->violence          = new Violence($data["violence"]);
//        $this->weapon            = new Weapon($data["weapon"]);
    }
}
