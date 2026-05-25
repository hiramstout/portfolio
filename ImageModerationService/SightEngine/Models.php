<?php

namespace App\Services\ImageModerationService\SightEngine;

class Models {
    const string gore = 'gore-2.0';
    const string aiDetection = 'genai';
    const string weapon = 'weapon';
    const string destruction = 'destruction';
    const string nudity = 'nudity-2.1';
    const string hateAndOffensive = 'offensive-2.0';
    const string money = 'money';
    const string recreationalDrug = 'recreational_drug';
    const string medicalDrugs = 'medical';
    const string selfHarm = 'self-harm';
    const string violence = 'violence';
    const string gambling = 'gambling';
    const string military = 'military';
}
