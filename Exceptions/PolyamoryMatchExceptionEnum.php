<?php

namespace App\Services\Exceptions;

enum PolyamoryMatchExceptionEnum: int
{
    case OtherException = 0;
    /* Used for code in which I am highly confident will not throw an exception
     * such as code which will never throw an exception assuming the logic is
     * correct (and thus might be due to mistyping on my end, but once identified
     * and corrected can be depended on to no longer throw exceptions)
     */
    case UnexpectedException = 1;
    // 1-599 correspond to http response codes

    /* 600 - 699 are critical exceptions, defined as involving one of the
     * following, and requiring direct admin action to resolve:
     * - Legal obligations/duties
     * - Critical user functions (making core features unusable/broken)
     * -
     * -
     */

    // "Harmful or abusive" in this case means that it may not meet the threshold of being illegal in every jurisdiction,
    // but would be at a minimum very disturbing content involving children
    case CSAMHarmfulAbusive = 665;
    case KnownCSAMDetected = 666;
    case PossibleKnownCSAMDetected = 667;
    case NovelCSAMDetected = 668;
    case CSAMAPIUnreachable = 669;

    /* 700 - 799
     *
     */


    /* 800 - 899
     *
     *
     */



    /* 900 - 999 involve events that are expected to occur, but must impede the
     * user/request flow (e.g. API request timeouts and adult imagery)
     *
     *TODO: Doesn't change user experience in any way, but does place a flag
     *      on the account as a likely future violator of the content
     *      moderation rules and conditions so that a stricter standard can
     *      be applied to any future uploads.
     */

    // Image moderation violations:
    // celebrities
    case AdultContent = 900;
    case ViolentContent = 901;
    case ChildrenPresent = 902;
    case AiOrDoctoredImage = 903;
    case SexuallySuggestiveContent = 904;
    case WeaponryContent = 905;
    case SelfHarm = 906;
    case HateContent = 907;
    case ContrabandContent = 908;
    case MoneyPresent = 909;
    case Harassment = 910;
    case VisuallyDisturbing = 911;
    case Gambling = 912;
    case Military = 913;

    // Image moderation API errors
    case RekognitionUnavailable = 920;
    case OpenAIModerationUnavailable = 921;
    case SightEngineUnavailable = 922;
    case GCPCloudVisionUnavailable = 923;
    case ModerationAPIAuthenticationFailed = 924;
    case ModerationServiceImageTooLarge = 925;
    case ModerationServiceInvalidFormat = 926;
    case ModerationAPILimitExceeded = 927;



    public function getLabel(): string {
        return match ($this) {
            PolyamoryMatchExceptionEnum::OtherException => 'Other Exception',
            PolyamoryMatchExceptionEnum::UnexpectedException => 'Unexpected Exception',
            PolyamoryMatchExceptionEnum::KnownCSAMDetected => 'Known CSAM Detected',
            PolyamoryMatchExceptionEnum::PossibleKnownCSAMDetected => 'Possible Known CSAM Detected',
            PolyamoryMatchExceptionEnum::NovelCSAMDetected => 'Novel CSAM Detected',
            PolyamoryMatchExceptionEnum::CSAMAPIUnreachable => 'CSAM API Unreachable',
            PolyamoryMatchExceptionEnum::AdultContent => 'Adult Content',
            PolyamoryMatchExceptionEnum::ViolentContent => 'Violent Content',
            PolyamoryMatchExceptionEnum::ChildrenPresent => 'Children Present',
            PolyamoryMatchExceptionEnum::AiOrDoctoredImage => 'AI or Doctored Content',
            PolyamoryMatchExceptionEnum::SexuallySuggestiveContent => 'Sexually Suggestive Content',
            PolyamoryMatchExceptionEnum::WeaponryContent => 'Weaponry Content',
            PolyamoryMatchExceptionEnum::SelfHarm => 'Self Harm',
            PolyamoryMatchExceptionEnum::HateContent => 'Hate Content',
            PolyamoryMatchExceptionEnum::ContrabandContent => 'Contraband Content',
            PolyamoryMatchExceptionEnum::MoneyPresent => 'Money Present',
            PolyamoryMatchExceptionEnum::Harassment => 'Harassment',
            PolyamoryMatchExceptionEnum::VisuallyDisturbing => 'Visually Disturbing',
            PolyamoryMatchExceptionEnum::Gambling => 'Gambling',
            PolyamoryMatchExceptionEnum::Military => 'Military',
            PolyamoryMatchExceptionEnum::RekognitionUnavailable => 'Moderation Service Unavailable',
            PolyamoryMatchExceptionEnum::OpenAIModerationUnavailable => 'Open AI Moderation Service Unavailable',
            PolyamoryMatchExceptionEnum::SightEngineUnavailable => 'Sight Engine Unavailable',
            PolyamoryMatchExceptionEnum::GCPCloudVisionUnavailable => 'GCP Cloud Vision Unavailable',
            PolyamoryMatchExceptionEnum::ModerationAPIAuthenticationFailed => 'Moderation API Authentication Failed',
            PolyamoryMatchExceptionEnum::ModerationServiceImageTooLarge => 'Moderation API Image Too Large',
            PolyamoryMatchExceptionEnum::ModerationServiceInvalidFormat => 'Moderation API Invalid Format',
            PolyamoryMatchExceptionEnum::ModerationAPILimitExceeded => 'Moderation API Limit Exceeded',
            default => 'Unknown Exception',
        };
    }

}
