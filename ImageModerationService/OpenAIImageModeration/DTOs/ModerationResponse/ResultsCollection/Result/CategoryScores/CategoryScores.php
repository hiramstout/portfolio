<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\CategoryScores;

class CategoryScores
{
    /**
     * @var float $sexual               Image & text moderation
     * @var float $selfHarmIntent       Image & text moderation
     * @var float $selfHarmInstructions Image & text moderation
     * @var float $selfHarm             Image & text moderation
     * @var float $violence             Image & text moderation
     * @var float $violenceGraphic      Image & text moderation
     */
    public float
        $sexual,
        $selfHarmIntent,
        $selfHarmInstructions,
        $selfHarm,
        $violence,
        $violenceGraphic;

    /**
     * @var float $harassment            Text moderation only
     * @var float $harassmentThreatening Text moderation only
     * @var float $sexualMinors          Text moderation only
     * @var float $hate                  Text moderation only
     * @var float $hateThreatening       Text moderation only
     * @var float $illicit               Text moderation only
     * @var float $illicitViolent        Text moderation only
     */

    public float
        $harassment,
        $harassmentThreatening,
        $sexualMinors,
        $hate,
        $hateThreatening,
        $illicit,
        $illicitViolent;

    public function __construct(array $data) {

        // Image and text moderation
        $this->sexual                = $data['sexual'];
        $this->selfHarmIntent        = $data['self-harm/intent'];
        $this->selfHarmInstructions  = $data['self-harm/instructions'];
        $this->selfHarm              = $data['self-harm'];
        $this->violence              = $data['violence'];
        $this->violenceGraphic       = $data['violence/graphic'];

        // Text moderation only
        $this->harassment            = $data['harassment'];
        $this->harassmentThreatening = $data['harassment/threatening'];
        $this->sexualMinors          = $data['sexual/minors'];
        $this->hate                  = $data['hate'];
        $this->hateThreatening       = $data['hate/threatening'];
        $this->illicit               = $data['illicit'];
        $this->illicitViolent        = $data['illicit/violent'];
    }
}
