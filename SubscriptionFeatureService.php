<?php 
namespace App\Services;
class SubscriptionFeatureService
{
    const FEATURES = [
        'free' => [
            'name' => 'Free Plan',
            'features' => [
              //  'swipes' => ['limit' => 100, 'period' => 'daily'],
                'likes' => ['limit' => 5, 'period' => 'daily'],
                'messages' => ['limit' => 10, 'period' => 'daily', 'type' => 'outgoing'],
                'photos' => ['limit' => 3],
                'profile_boosts' => ['limit' => 0, 'period' => 'weekly'],
                'hard_no' => false,
                'read_receipts' => false,
                'event_discount' => 0,
                'advanced_filters' => false,
                'see_who_liked_you' => false,
            ]
        ],
        
        'standard' => [
            'name' => 'Standard Plan',
            'features' => [
                //'swipes' => ['limit' => 200, 'period' => 'daily'],
                'likes' => ['limit' => 15, 'period' => 'daily'],
                'messages' => ['limit' => 30, 'period' => 'daily', 'type' => 'outgoing'],
                'photos' => ['limit' => 6],
                'profile_boosts' => ['limit' => 3, 'period' => 'weekly', 'duration' => 30],
                'hard_no' => true,
                'read_receipts' => true,
                'event_discount' => 10,
                'advanced_filters' => true,
                'see_who_liked_you' => true,
            ]
        ],
        
        'vip' => [
            'name' => 'VIP Plan',
            'features' => [
                //'swipes' => ['limit' => null, 'period' => 'daily'], // unlimited
                'likes' => ['limit' => null, 'period' => 'daily'], // unlimited
                'messages' => ['limit' => null, 'period' => 'daily', 'type' => 'outgoing'], // unlimited
                'photos' => ['limit' => 8],
                'profile_boosts' => ['limit' => 5, 'period' => 'weekly', 'duration' => 60],
                'hard_no' => true,
                'read_receipts' => true,
                'event_discount' => 20,
                'advanced_filters' => true,
                'see_who_liked_you' => true,
            ]
        ]
    ];

    public function getFeatures($plan)
    {
        return self::FEATURES[strtolower($plan)] ?? self::FEATURES['free'];
    }

    public function getFeatureValue($plan, $feature)
    {
        $planFeatures = self::FEATURES[strtolower($plan)] ?? self::FEATURES['free'];
        return $planFeatures['features'][$feature] ?? null;
    }

    public function isFeatureAvailable($plan, $feature)
    {
        $value = $this->getFeatureValue($plan, $feature);
        
        if (is_bool($value)) {
            return $value;
        }
        
        if (is_array($value) && isset($value['limit'])) {
            return $value['limit'] === null || $value['limit'] > 0;
        }
        
        return false;
    }

    public function getFeatureLimit($plan, $feature)
    {
        $value = $this->getFeatureValue($plan, $feature);
        return is_array($value) ? ($value['limit'] ?? null) : null;
    }
}

?>