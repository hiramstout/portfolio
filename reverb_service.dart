import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:polymory_match/models/UserPreferences.dart';
import 'package:polymory_match/services/DTOs/WebsocketEvent.dart';
import 'package:polymory_match/services/local_message_repository.dart';
import 'package:polymory_match/utils/api_constants.dart';  // your constants
import 'package:polymory_match/widgets/feature_issue_dialog.dart';
import '../models/ChatMessage.dart';
import '../models/InAppNotification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ReverbService {
  Timer? _heartbeatTimer;

  void _startHeartbeat() {
    debugPrint('start-heart-beat');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_channel == null) {
        _heartbeatTimer?.cancel();
        _heartbeatTimer = null;
        return;
      }
      _sendHeartbeat();
    });
  }

  Future<void> _sendHeartbeat() async {
    debugPrint('scheduled-heart-beat');
    final token = await UserPreferences.getToken();
    if (token == null || _channel == null) return;
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/heartbeat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }
      );
      debugPrint('send-heartbeat-response:\n  code: ${response.statusCode}\n  body: ${response.body}');
    } catch (_) {
      // Silently ignore.
    }
  }

  WebSocketChannel? _channel;
  String? _socketId;

  // ============= Notification broadcast ===============
  final StreamController<InAppNotification> _notificationController =
  StreamController<InAppNotification>.broadcast();

  /// Listen to this stream from the overlay to get new message events.
  Stream<InAppNotification> get notificationStream =>
      _notificationController.stream;

  // ============= Connection state =================
  bool get connected => _channel != null;

  // ======== Reverb presence online users ===============
  List<ChatUser> onlineUsers = [];

  // ========== Currently logged in user =================
  ChatUser? _currentUser;

  // ============== Connect to the WebSocket =============
  Future<void> connect(
    String token,
    BuildContext context
  ) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(ApiConstants.webSocketUrl));
      debugPrint('channel assigned');
    } catch (e) {
      debugPrint('$e');
      Future.delayed(
        const Duration(seconds: 2),
        () => context.mounted ? connect(token,context) : null
      );
    }
    _channel!.stream.listen(
        (raw) {
          debugPrint('New RAW: $raw');
          final data = raw;
          debugPrint('data: $data');
          _handleIncoming(data);
          debugPrint('handleIncoming was called');
        },
        onError: (err) => debugPrint('x WebSocket error: $err'),
        onDone: () {
          debugPrint('Websocket closed, reconnecting...');
          _heartbeatTimer?.cancel();
          _heartbeatTimer = null;
          if (context.mounted) connect(token, context);
        }
    );
  }

  Future<void> _handleIncoming(
    String data
  ) async {
    try {
      debugPrint('reverb-data: $data');
      final response = RawReverbEvent.unmarshall(data);
      debugPrint('reverb-event:\n${response.toString()}');

      switch (response.eventName) {
        case ReverbEventTypes.connectionEstablished:
          final Map<String,dynamic> dataMap = jsonDecode(response.data!);
          debugPrint('$dataMap');
          _socketId = dataMap['socket_id'];
          _startHeartbeat();
          debugPrint('Socket ID: $_socketId connected');
          // auto-subscribe to required channels here
          final userId = await UserPreferences.getUserId();
          debugPrint('subscribeToChannel(\'private-App.Models.User.$userId\', _socketId!, context.mounted ? context : context);');
          subscribePresenceChanel(ReverbChannels.presenceConversation.channelName, _socketId!);
          subscribeToChannel('private-App.Models.User.$userId', _socketId!);
          break;
        case ReverbEventTypes.privateMessageSent: // Verified!
          final messageResponse = PrivateMessageSentEventBody.unmarshal(response.data!);
          _handlePrivateMessageEvent(messageResponse);
          break;
        case ReverbEventTypes.groupCreated: // TODO: Verify
          final messageResponse = GroupCreatedEventBody.unmarshall(response.data!);
          _handleNewGroupEvent(messageResponse);
          break;
        case ReverbEventTypes.groupMessageSent: // Verified!
          final messageResponse = GroupMessageSentEventBody.unmarshall(response.data!);
          _handleGroupMessageEvent(messageResponse);
          break;
        case ReverbEventTypes.userMatched: // TODO: Verify
          final messageResponse = UserMatchedEventBody.unmarshall(response.data!);
          _handleUserMatchedEvent(messageResponse);
          break;
        case ReverbEventTypes.memberAdded: // Verified!
          final messageResponse = MemberAddedEventBody.unmarshall(response.data!);
          _handleMemberAddedEvent(messageResponse);
          break;
        case ReverbEventTypes.memberRemoved: // Verified!
          final messageResponse = MemberRemovedEventBody.unmarshall(response.data!);
          _handleMemberRemovedEvent(messageResponse);
          break;
        case ReverbEventTypes.messageDelivered: // Verified!
          final messageResponse = MessageStatusUpdateEventBody.unmarshal(response.data!);
          LocalMessageRepository.updateMessageStatus(
            messageId: messageResponse.messageId,
            isDelivered: true
          );
          _messageStatusController.add(messageResponse);
          break;
        case ReverbEventTypes.messageRead: // Verified!
          final messageResponse = MessageStatusUpdateEventBody.unmarshal(response.data!);
          LocalMessageRepository.updateMessageStatus(
              messageId: messageResponse.messageId,
              isRead: true
          );
          _messageStatusController.add(messageResponse);
          break;
        case ReverbEventTypes.ping: // Verified!
          _handlePingEvent();
          break;
        case ReverbEventTypes.subscriptionSucceeded: // Verified!
          if (response.channel == ReverbChannels.presenceConversation) {
            final messageResponse = PresenceSubscriptionSucceededEventBody.unmarshall(response.data!);
            _handlePresenceSubscriptionEvent(messageResponse);
          } else {
            debugPrint('Private subscription succeeded. Response: ${response.data}');
          }
          break;
        case ReverbEventTypes.userTyping: // TODO: Need to verify
          final messageResponse = UserTypingEventBody.fromJson(response.data!);
          _typingEventController.add(messageResponse);
          break;
      }

      return;
    } catch (e) {
      debugPrint('ERROR ERROR CRITICAL ERROR SYSTEM FAILURE: $e');
      return;
    }
  }

  final StreamController<ChatMessage> _messageController = StreamController.broadcast();
  Stream<ChatMessage> get messageStream
    => _messageController.stream;

  final StreamController<MessageStatusUpdateEventBody> _messageStatusController = StreamController.broadcast();
  Stream<MessageStatusUpdateEventBody> get messageStatusStream
    => _messageStatusController.stream;

  final StreamController<UserTypingEventBody> _typingEventController = StreamController.broadcast();
  Stream<UserTypingEventBody> get typingEventStream
    => _typingEventController.stream;

  final StreamController<UserMatchedEventBody> _userMatchController = StreamController.broadcast();
  Stream<UserMatchedEventBody> get userMatchStream
    => _userMatchController.stream;

  final StreamController<MemberRemovedEventBody> _memberRemovedController = StreamController.broadcast();
  Stream<MemberRemovedEventBody> get memberRemovedStream
    => _memberRemovedController.stream;

  final StreamController<MemberAddedEventBody> _memberAddedController = StreamController.broadcast();
  Stream<MemberAddedEventBody> get memberAddedStream
    => _memberAddedController.stream;

  final StreamController<GroupCreatedEventBody> _newGroupController = StreamController.broadcast();
  Stream<GroupCreatedEventBody> get newGroupStream
    => _newGroupController.stream;

  final StreamController<PresenceSubscriptionSucceededEventBody> _userStatusUpdatedController = StreamController.broadcast();
  Stream<PresenceSubscriptionSucceededEventBody> get userStatusUpdatedStream
    => _userStatusUpdatedController.stream;

  void _handlePresenceSubscriptionEvent(
    PresenceSubscriptionSucceededEventBody response
  ) async {

    onlineUsers = [];
    final int? userId = await UserPreferences.getUserId();
    final String? firstName = await UserPreferences.getFirstName();
    final String? lastName = await UserPreferences.getLastName();
    _currentUser = ChatUser(
      id: userId!,
      firstName: firstName!,
      lastName: lastName!
    );

    for (final user in response.presenceData.hashData.userMap.entries) {
      if (user.value.id != _currentUser!.id) {
        String userFirstName = '';
        String userLastName = '';
        int i = 0;
        for (final name in user.value.name.split(' ')) {
          switch (i) {
            case 0:
              userFirstName = name;
              break;
            case 1:
              userLastName = name;
              break;
            case >1:
              userLastName += ' $name';
              break;
          }
          i++;
        }

        onlineUsers.add(
          ChatUser(
            id: user.value.id,
            firstName: userFirstName,
            lastName: userLastName
          )
        );
      }
    }

    _userStatusUpdatedController.add(response);
  }

  void _handlePingEvent() {
    debugPrint('ping');
    final data = {
      'event': 'pusher:pong',
      'data': {}
    };
    _channel!.sink.add(jsonEncode(data));
    debugPrint('pong');
  }

  void _handleMemberAddedEvent(
    MemberAddedEventBody eventBody
  ) {
    debugPrint('Presence user online');
    String firstName = '';
    String lastName = '';
    List<String> nameArray = eventBody.userData.name.split(' ');
    int i = 0;
    for (final name in nameArray) {
      if (i == 0) {
        firstName = name;
      } else if (i == 1) {
        lastName = name;
      } else {
        lastName += ' $name';
      }
      i++;
    }

    if (eventBody.userData.id != _currentUser!.id) {
      onlineUsers.add(
        ChatUser(
          id: eventBody.userData.id,
          firstName: firstName,
          lastName: lastName
        )
      );
      _memberAddedController.add(eventBody);
    }
  }

  void _handleMemberRemovedEvent(
    MemberRemovedEventBody response
  ) {
    debugPrint('Presence user online offline');

    if (int.parse(response.userId) != _currentUser!.id) {
      onlineUsers.removeWhere(
        (user)
          => user.id == int.parse(response.userId)
      );
      _memberRemovedController.add(response);
    }
  }

  void _handleUserMatchedEvent(
    UserMatchedEventBody response
  ) {
    try {
      final notification = InAppNotification(
        title: response.matchedUser.name,
          body: response.message,
          conversationId: response.conversationId,
          type: 'match',
          senderId: response.matchedUser.id,
          timeSent: DateTime.now()
      );
      _notificationController.add(notification);
      _userMatchController.add(response);
    } catch (e) {
      debugPrint('Error handling user matched event ${e.toString()}');
    }
  }

  void _handleNewGroupEvent(
    GroupCreatedEventBody response
  ) {
    try {
      final notification = InAppNotification(
        title: response.groupData.name,
        body: response.message,
        conversationId: response.groupData.conversationId,
        type: 'group',
        senderId: response.groupData.id,
        profileImage: response.groupData.profileImageUrl,
        timeSent: DateTime.now()
      );
      _newGroupController.add(response);
      _notificationController.add(notification);
    } catch (e) {
      debugPrint('Error handling new group event ${e.toString()}');
    }
  }
  void _handleGroupMessageEvent(
    GroupMessageSentEventBody eventBody
  ) {
    try {
      final List<String> nameArray = eventBody.message.user!.name.split(' ');
      String firstName = '';
      String lastName = '';
      int i = 0;
      for (var name in nameArray) {
        if (i == 0) {
          firstName = name;
        } else if (i == 1) {
          lastName = name;
        } else {
          lastName += ' $name';
        }
        i++;
      }
      final List<ChatAttachment> chatAttachments = [];
      if (eventBody.message.attachments.isNotEmpty) {
        final currentAttachments = eventBody.message.attachments;
        for (final attachment in currentAttachments) {
          chatAttachments.add(
            ChatAttachment(
              id: attachment.id,
              name: attachment.name,
              mime: attachment.mime,
              size: attachment.size,
              fullPath: attachment.url.toString(),
            )
          );
        }
      }
      final chatMessage = ChatMessage(
        id: eventBody.message.id,
        conversationId: eventBody.message.conversationId,
        userId: eventBody.message.user!.id,
        body: eventBody.message.body,
        createdAt: eventBody.message.createdAt,
        user: ChatUser(
          id: eventBody.message.user!.id,
          firstName: firstName,
          lastName: lastName
        ),
        attachments: chatAttachments,
        isDelivered: true,
        profileImgUrl: eventBody.message.user!.profilesImageUrl
      );
      final notification = InAppNotification(
        title: eventBody.message.user!.name,
        body: eventBody.message.body,
        conversationId: eventBody.message.conversationId,
        type: eventBody.message.messageType.rawValue,
        senderId: eventBody.message.user!.id,
        profileImage: eventBody.message.user!.profilesImageUrl,
        timeSent: eventBody.message.createdAt
      );
      LocalMessageRepository.insertMessages([chatMessage]);
      _messageController.add(chatMessage);
      _notificationController.add(notification);
      debugPrint('In-app notification queued: ${eventBody.message.user?.name} - ${eventBody.message.body}');
    } catch (e) {
      debugPrint('Could not parse message for notification: $e');
    }
  }

  void _handlePrivateMessageEvent(
      PrivateMessageSentEventBody eventBody
  ) {
    try {
      final List<String> nameArray = eventBody.message.user!.name.split(' ');
      String firstName = '';
      String lastName = '';
      int i = 0;
      for (var name in nameArray) {
        if (i == 0) {
          firstName = name;
        } else if (i == 1) {
          lastName = name;
        } else {
          lastName += ' $name';
        }
        i++;
      }
      final List<ChatAttachment> chatAttachments = [];
      if (eventBody.message.attachments.isNotEmpty) {
        final currentAttachments = eventBody.message.attachments;
        for (final attachment in currentAttachments) {
          chatAttachments.add(
            ChatAttachment(
                id: attachment.id,
                name: attachment.name,
                mime: attachment.mime,
                size: attachment.size,
                fullPath: attachment.url.toString(),
            )
          );
        }
      }
      final chatMessage = ChatMessage(
        id: eventBody.message.id,
        conversationId: eventBody.message.conversationId,
        userId: eventBody.message.user!.id,
        body: eventBody.message.body,
        createdAt: eventBody.message.createdAt,
        user: ChatUser(
          id: eventBody.message.user!.id,
          firstName: firstName,
          lastName: lastName
        ),
        attachments: chatAttachments,
        isDelivered: true,
        profileImgUrl: eventBody.message.user!.profileImageUrl
      );
      final notification = InAppNotification(
        title: eventBody.message.user!.name,
        body: eventBody.message.body,
        conversationId: eventBody.message.conversationId,
        type: eventBody.message.messageType.rawValue,
        senderId: eventBody.message.user!.id,
        profileImage: eventBody.message.user!.profileImageUrl,
        timeSent: eventBody.message.createdAt
      );
      LocalMessageRepository.insertMessages([chatMessage]);
      _messageController.add(chatMessage);
      _notificationController.add(notification);
      debugPrint('In-app notification queued: ${eventBody.message.user?.name} - ${eventBody.message.body}');
    } catch (e) {
      debugPrint('Could not parse message for notification: $e');
    }
  }

  Future<String> fetchAuthSignature(String socketId, String channelName) async {
    // Implement your auth call using http package
    final token = await UserPreferences.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.broadcastingAuthUrl),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "socket_id": socketId,
        "channel_name": channelName
      })
    );

    debugPrint('Broadcasting auth response for channel name: $channelName : ${response.statusCode}, ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['auth'];
    } else if (response.statusCode == 521) {
      fetchAuthSignature(socketId, channelName);
    }
    throw Exception('Broadcasting auth failed: ${response.statusCode} ${response.body}');
  }

  static const int _featureIssueErrorCodeAuth = 9234;

  Future<void> _showFeatureIssuePopup(
    BuildContext context,
    String details
  ) async {
    await showFeatureIssueDialog(
        context: context,
        errorCode: _featureIssueErrorCodeAuth,
        technicalDetails: details
    );
  }

  void subscribeToChannel(
      String channel,
      String socketId
  ) async {
    // authentication similar to your current subscribeToChannel method
    // After auth, _channel!.sink.add({'event':'pusher:subscribe','data':{'channel':channel,'auth':auth}} );
    try {
      final auth = await fetchAuthSignature(socketId,channel);
      final message = {
        'event': 'pusher:subscribe',
        'data': {
          'channel': channel,
          'auth': auth
        },
      };
      debugPrint('subscribing to private user channel: $message');
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      // TODO: Show feature issue dialog box
      debugPrint('Websocket channel subscription failed: ${e.toString()}');
    }
  }

  Future<void> subscribePresenceChanel(
    String channelName,
    String socketId,
  ) async {
    try {
      final token = await UserPreferences.getToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.broadcastingAuthUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'socket_id': socketId,
          'channel_name': channelName
        }),
      );

      debugPrint('Broadcasting auth response for presence channel ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final auth = data['auth'];
        final channelData = data['channel_data'];

        final message = {
          'event': 'pusher:subscribe',
          'data': {
            'channel': channelName,
            'auth': auth,
            // Required for presence channels
            'channel_data': channelData
          }
        };
        debugPrint(
          'Subscribing to $channelName with auth: $auth and channel_data: $channelData'
        );
        _channel!.sink.add(jsonEncode(message));
      } else {
        throw Exception('Auth failed: ${response.statusCode}${response.body}');
      }
    } catch (e) {
      debugPrint('Websocket subscription failed: $e');
    }
  }


  void disconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _channel?.sink.close();
    _channel = null;
    debugPrint('WebSocket disconnected');
  }



  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
