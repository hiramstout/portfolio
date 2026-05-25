import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screens/individual_chat.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
= FlutterLocalNotificationsPlugin();


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 1. Initialize Firebase (required)
  await Firebase.initializeApp();

  // 2. Show the local notification (with profile image)
  _showLocalNotification(message);

  // 3. Mark the message as delivered
  final data = message.data;
  final messageId = data['message_id'];
  if (messageId != null) {
    try {
      final prefs = await SharedPreferences.getInstance();
      // IMPORTANT: replace 'auth_token' with the exact key used by UserPreferences.getToken()
      final token = prefs.getString('auth_token');
      if (token != null) {
        await http.post(
          Uri.parse('https://polyamorymatch.com/api/user/message/$messageId/delivered'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (_) {
      // If it fails, delivery will be marked retroactively when the user opens the app.
    }
  }
}


Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;
  final String? profileImageUrl = data['profile_image'];

  // Download profile image if available
  String? imagePath;
  if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(profileImageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/notification_profile_${message.messageId}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        imagePath = file.path;
      }
    } catch (_) {
      // Silently ignore – notification will fall back to default icon
    }
  }

  // ─── Android configuration ───
  final AndroidNotificationDetails androidDetails;
  if (imagePath != null) {
    androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Poly Messages',
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: FilePathAndroidBitmap(imagePath),                    // small icon in collapsed view
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(imagePath),                             // expanded big picture
        largeIcon: FilePathAndroidBitmap(imagePath),
        contentTitle: notification?.title,
        summaryText: notification?.body,
      ),
    );
  } else {
    androidDetails = const AndroidNotificationDetails(
      'high_importance_channel',
      'Poly Messages',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  // ─── iOS configuration ───
  final DarwinNotificationDetails darwinDetails;
  if (imagePath != null) {
    darwinDetails = DarwinNotificationDetails(
      attachments: [
        DarwinNotificationAttachment(
          imagePath,
          identifier: 'profile_image',
        ),
      ],
    );
  } else {
    darwinDetails = const DarwinNotificationDetails();
  }

  final platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.messageId.hashCode,
    notification?.title ?? 'New message',
    notification?.body ?? '',
    platformDetails,
    payload: jsonEncode(data),
  );
}

class NotificationService {

  static Future<void> init() async {
    try {
      debugPrint('🔥 Firebase.initializeApp starting ...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase.initializeApp completed');
    } catch (e, stack) {
      debugPrint('❌ Firebase.initializeApp failed: $e');
      debugPrint('Stack: $stack');

      if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (ctx) => AlertDialog(
            title: const Text('Firebase Init Error'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      rethrow;
    }

    // ─── Both Android AND iOS initialization settings ───
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,   // we handle it ourselves
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      _showLocalNotification(message);
      final messageId = message.data['message_id'];
      if (messageId != null) {
        try {
          await ApiService.delivermsg(int.parse(messageId));
        } catch (_) {}
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      _navigateToChat(data);
    }
  }



  static void _onNotificationOpenedApp(RemoteMessage message) {
    _navigateToChat(message.data);
  }

  static void _navigateToChat(Map<String,dynamic> data) {
    final conversationId = int.tryParse(data['conversation_id'] ?? '');
    if (conversationId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_)
          => ChatScreen2(
            conversationId: conversationId,
            profileimg: data['profile_image'],
            name: data['sender_name'],
            type: data['type'] ?? 'private'
          )
        )
      );
    }
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static const _askedKey = 'notification_permission_asked';

  static Future<bool> get isGranted async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized
          || settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Use permission_handler for Android 13+
        final status = await Permission.notification.status;
        return status.isGranted;
      }
    }
    // Fallback for older Android (granted via manifest)
    return true;
  }

  /// Returns `true` if we have ever shown the permission prompt on this device.
  static Future<bool> get hasAsked async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_askedKey) ?? false;
  }
  /// Mark that we have shown the permission prompt (regardless of outcome).
  static Future<void> markAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
  }

  /// Request system notification permissions.
  /// Call this only after the user tapped "Allow" in your pre-prompt
  static Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      // iOS: FirebaseMessaging.requestPermission handles the system popup
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized
          || settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      // Android 13+ needs runtime permission
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }
}
