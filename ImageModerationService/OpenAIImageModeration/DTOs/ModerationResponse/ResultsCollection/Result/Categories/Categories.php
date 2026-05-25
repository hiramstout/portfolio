<?php

namespace App\Services\ImageModerationService\OpenAIImageModeration\DTOs\ModerationResponse\ResultsCollection\Result\Categories;

class Categories
{
    /**
     * @var bool $sexual               Image & text moderation
     * @var bool $selfHarmIntent       Image & text moderation
     * @var bool $selfHarmInstructions Image & text moderation
     * @var bool $selfHarm             Image & text moderation
     * @var bool $violence             Image & text moderation
     * @var bool $violenceGraphic      Image & text moderation
     */
    public bool
        $sexual,
        // TODO: Instruct users on resources in their country that they can reach out to if they are mentally unwell
        $selfHarmIntent,
        $selfHarmInstructions,
        $selfHarm,
        $violence,
        $violenceGraphic;

    /**
     * @var bool $harassment            Text moderation only
     * @var bool $harassmentThreatening Text moderation only
     * @var bool $sexualMinors          Text moderation only
     * @var bool $hate                  Text moderation only
     * @var bool $hateThreatening       Text moderation only
     * @var bool $illicit               Text moderation only
     * @var bool $illicitViolent        Text moderation only
     */

    public bool
        $harassment,
        $harassmentThreatening,
        $sexualMinors,
        $hate,
        $hateThreatening,
        $illicit,
        $illicitViolent;

    public function __construct(array $data) {

        // Image and text moderation
        $this->sexual = $data['sexual'];
        $this->selfHarmIntent = $data['self-harm/intent'];
        $this->selfHarmInstructions = $data['self-harm/instructions'];
        $this->selfHarm = $data['self-harm'];
        $this->violence = $data['violence'];
        $this->violenceGraphic = $data['violence/graphic'];

        // Text moderation only
        $this->harassment = $data['harassment'];
        $this->harassmentThreatening = $data['harassment/threatening'];
        $this->sexualMinors = $data['sexual/minors'];
        $this->hate = $data['hate'];
        $this->hateThreatening = $data['hate/threatening'];
        $this->illicit = $data['illicit'];
        $this->illicitViolent = $data['illicit/violent'];
    }
}
