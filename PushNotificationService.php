<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Exception\FirebaseException;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

class PushNotificationService
{
    public function sendToUser(User $user, string $title, string $body, array $data = []): void
    {
        try {
            Log::alert('FCM Notification delivery attempt started. FCM token: ' . $user->fcm_token ? $user->fcm_token : 'NO TOKEN!');
            if (!$user->fcm_token) return;

            $factory = (new Factory())
                ->withServiceAccount(storage_path('app/firebase-service-account.json'))
                ->withProjectId('poyamory-match-v1');
            $messaging = $factory->createMessaging();
            Log::alert('token ' . $user->fcm_token . ' title: ' . $title . ' body: ' . $body . ' data: ');

            $message = CloudMessage::fromArray([
                'token' => $user->fcm_token,
                'notification' => [
                    'title' => $title,
                    'body' => $body
                ],
                'data' => $data
            ]);
            $messaging->send($message);
        } catch (FirebaseException|MessagingException $exception) {
          Log::critical("Exception occurred:\n". $exception->getMessage() . "\n" . $exception->getTraceAsString());
        }
    }
}
