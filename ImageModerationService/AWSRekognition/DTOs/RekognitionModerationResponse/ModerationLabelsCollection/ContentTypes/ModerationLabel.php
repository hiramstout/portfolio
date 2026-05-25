<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes;

use App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes\ModerationLabelEnum;
use PhpParser\Node\Expr\AssignOp\Mod;

/**
 * @property $confidence JSON field name "Confidence". Value between 0 to 100
 * @property $name JSON field name "Name". Label name for the type of unsafe content detected in the image
 * @property $parentName JSON field name "ParentName". The name of the parent label. Labels at the top of the taxonomy hierarchy have the parent label ""
 * @property $taxonomyLevel JSON field name "TaxonomyLevel". The level of the moderation label in regards to its taxonomy, from 1 to 3
 */
class ModerationLabel {
    public ?int $confidence;
    public ModerationLabelEnum $name;
    public ?string $parentName;
    public ?int $taxonomyLevel;

    public function __construct(
        array $data
    ) {
        $this->confidence = $data['Confidence'];
        $this->name = ModerationLabelEnum::tryFrom($data['Name']) ?? ModerationLabelEnum::na;
        $this->parentName = $data['ParentName'];
        $this->taxonomyLevel = $data['TaxonomyLevel'];
    }
}
