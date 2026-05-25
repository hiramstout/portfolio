<?php

namespace App\Services\ImageModerationService\AWSRekognition\DTOs\RekognitionModerationResponse\ModerationLabelsCollection\ContentTypes;
enum ModerationLabelEnum: string {
    case exposedMaleGenitalia         = "Exposed Male Genitalia";
    case exposedFemaleGenitalia       = "Exposed Female Genitalia";
    case exposedButtocksOrAnus        = "Exposed Buttocks or Anus";
    case exposedFemaleNipple          = "Exposed Female Nipple";
    case explicitSexualActivity       = "Explicit Sexual Activity";
    case sexToys                      = "Sex Toys";
    case bareBack                     = "Bare Back";
    case exposedMaleNipple            = "Exposed Male Nipple";
    case partiallyExposedButtocks     = "Partially Exposed Buttocks";
    case partiallyExposedFemaleBreast = "Partially Exposed Female Breast";
    case impliedNudity                = "Implied Nudity";
    case obstructedFemaleNipple       = "Obstructed Female Nipple";
    case obstructedMaleGenitalia      = "Obstructed Male Genitalia";
    case kissingOnTheLips             = "Kissing on the Lips";
    case femaleSwimwearOrUnderwear    = "Female Swimwear or Underwear";
    case maleSwimwearOrUnderwear      = "Male Swimwear or Underwear";
    case weapons                      = "Weapons";
    case weaponViolence               = "Weapon Violence";
    case physicalViolence             = "Physical Violence";
    case selfHarm                     = "Self-Harm";
    case bloodAndGore                 = "Blood & Gore";
    case explosionsAndBlasts          = "Explosions and Blasts";
    case emaciatedBodies              = "Emaciated Bodies";
    case corpses                      = "Corpses";
    case airCrash                     = "Air Crash";
    case pills                        = "Pills";
    case smoking                      = "Smoking";
    case drinking                     = "Drinking";
    case alcoholicBeverages           = "Alcoholic Beverages";
    case middleFinger                 = "Middle Finger";
    case gambling                     = "Gambling";
    case naziParty                    = "Nazi Party";
    case whiteSupremacy               = "White Supremacy";
    case extremist                    = "Extremist";
    case animated                     = "Animated";
    case na                           = "N/A";
}
