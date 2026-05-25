<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\CategoryAppliedInputTypes;

class CategoryAppliedInputTypes {
    public AppliedInputTypes
        $sexual,
        $selfHarmIntent,
        $selfHarmInstructions,
        $selfHarm,
        $violence,
        $violenceGraphic;

    public AppliedInputTypes
        $harassment,
        $harassmentThreatening,
        $sexualMinors,
        $hate,
        $hateThreatening,
        $illicit,
        $illicitViolent;

    public function __construct(array $data) {

        // Image and text moderation
        $this->sexual                = new AppliedInputTypes($data["sexual"]);
        $this->selfHarmIntent        = new AppliedInputTypes($data["self-harm/intent"]);
        $this->selfHarmInstructions  = new AppliedInputTypes($data["self-harm/instructions"]);
        $this->selfHarm              = new AppliedInputTypes($data["self-harm"]);
        $this->violence              = new AppliedInputTypes($data["violence"]);
        $this->violenceGraphic       = new AppliedInputTypes($data["violence/graphic"]);

        // Text moderation only
        $this->harassment            = new AppliedInputTypes($data["harassment"]);
        $this->harassmentThreatening = new AppliedInputTypes($data["harassment/threatening"]);
        $this->sexualMinors          = new AppliedInputTypes($data["sexual/minors"]);
        $this->hate                  = new AppliedInputTypes($data["hate"]);
        $this->hateThreatening       = new AppliedInputTypes($data["hate/threatening"]);
        $this->illicit               = new AppliedInputTypes($data["illicit"]);
        $this->illicitViolent        = new AppliedInputTypes($data["illicit/violent"]);
    }

    public function toArray(): array {
        return [
            "sexual" => $this->sexual->toArray(),
            "self-harm" => $this->selfHarm->toArray(),
            "self-harm/intent" => $this->selfHarmIntent->toArray(),
            "self-harm/instructions" => $this->selfHarmInstructions->toArray(),
            "violence" => $this->violence->toArray(),
            "violence/graphic" => $this->violenceGraphic->toArray(),
            "harassment" => $this->harassment->toArray(),
            "harassment/threatening" => $this->harassmentThreatening->toArray(),
            "sexual/minors" => $this->sexualMinors->toArray(),
            "hate" => $this->hate->toArray(),
            "hate/threatening" => $this->hateThreatening->toArray(),
            "illicit" => $this->illicit->toArray(),
            "illicit/violent" => $this->illicitViolent->toArray(),
        ];
    }
}
