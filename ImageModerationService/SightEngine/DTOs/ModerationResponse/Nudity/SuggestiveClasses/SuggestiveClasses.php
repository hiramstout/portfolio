<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses;

use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses\CleavageCategories\CleavageCategories;
use App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\Nudity\SuggestiveClasses\MaleChestCategories\MaleChestCategories;

class SuggestiveClasses {
    public float $cleavage;
    public float $lingerie;
    public float $maleChest;
    public float $maleUnderwear;
    public float $miniskirt;
    public float $other;
    public float $miniShort;
    public float $nudityArt;
    public float $schematic;
    public float $sexToy;
    public float $suggestiveFocus;
    public float $suggestivePose;
    public float $swimwearMale;
    public float $swimwearOnePiece;
    public float $visiblyUndressed;

    public CleavageCategories $cleavageCategories;
    public MaleChestCategories $maleChestCategories;

    public function __construct(array $data) {
        $this->cleavage = $data['cleavage'];
        $this->lingerie = $data['lingerie'];
        $this->maleChest = $data['male_chest'];
        $this->maleUnderwear = $data['male_underwear'];
        $this->miniskirt = $data['miniskirt'];
        $this->other = $data['other'];
        $this->miniShort = $data['minishort'];
        $this->nudityArt = $data['nudity_art'];
        $this->schematic = $data['schematic'];
        $this->sexToy = $data['sextoy'];
        $this->suggestiveFocus = $data['suggestive_focus'];
        $this->suggestivePose = $data['suggestive_pose'];
        $this->swimwearMale = $data['swimwear_male'];
        $this->swimwearOnePiece = $data['swimwear_one_piece'];
        $this->visiblyUndressed = $data['visibly_undressed'];
        $this->cleavageCategories = new CleavageCategories($data['cleavage_categories']);
        $this->maleChestCategories = new MaleChestCategories($data['male_chest_categories']);
    }
}
