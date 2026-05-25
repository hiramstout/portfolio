<?php

namespace App\Services\ImageModerationService\CloudVisionAI\DTOs;
class SafeSearchModerationResponse
{
    public LikelihoodEnum $adult;
    public LikelihoodEnum $spoof;
    public LikelihoodEnum $medical;
    public LikelihoodEnum $violence;
    public LikelihoodEnum $racy;

    public function __construct(string $responseData) {
        if (
            array_key_exists(
                'safeSearchAnnotation',
                json_decode(
                    $responseData,
                    associative: true
                )['responses'][0]
            )
        ) {
            $annotationResult = json_decode($responseData, true)['responses'][0]['safeSearchAnnotation'];

            $this->adult    = LikelihoodEnum::tryFrom($annotationResult['adult']);
            $this->spoof    = LikelihoodEnum::tryFrom($annotationResult['spoof']);
            $this->medical  = LikelihoodEnum::tryFrom($annotationResult['medical']);
            $this->violence = LikelihoodEnum::tryFrom($annotationResult['violence']);
            $this->racy     = LikelihoodEnum::tryFrom($annotationResult['racy']);
        } else {
            $this->adult = LikelihoodEnum::unknown;
            $this->spoof = LikelihoodEnum::unknown;
            $this->medical = LikelihoodEnum::unknown;
            $this->violence = LikelihoodEnum::unknown;
            $this->racy = LikelihoodEnum::unknown;
        }
    }
}
