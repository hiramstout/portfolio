import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:polymory_match/utils/api_constants.dart';

class RawReverbEvent {
  final ReverbEventTypes eventName;
  final ReverbChannels? channel;
  // JSON String, must be decoded again
  final String? data;

  const RawReverbEvent(
    this.eventName,
    this.channel,
    this.data
  );

  factory RawReverbEvent.unmarshall(String payload) {
    debugPrint('RawReverbEvent.unmarshall: $payload');
    final Map<String,dynamic> response = jsonDecode(payload);
    debugPrint('$response');
    final event = ReverbEventTypes.fromString(response['event']);
    if (event == null) throw Exception('unimplemented');
    debugPrint('event parsing SUCCESS, NICE JOB!!');
    ReverbChannels? channel;
    channel = null;
    if (response.keys.contains('channel')) {
      channel = ReverbChannels.fromString(response['channel']);
    }
    debugPrint('event: $event, channel: $channel, data: ${response['data']}');
    return RawReverbEvent(
      event,
      channel,
      response['data']
    );
  }
}
class GroupData {
  final int id;
  final String name;
  final String createdAt;
  final int conversationId;
  final Uri profileImageUrl;
  const GroupData(this.id,this.name,this.createdAt,this.conversationId,this.profileImageUrl);
  factory GroupData.fromMap(Map<String,dynamic> map) {
    debugPrint('GroupData.fromMap: $map');
    return GroupData(
      map['id'] as int,
      map['name'] as String,
      map['created_at'] as String,
      map['conversation_id'] as int,
      Uri.parse('https://polyamorymatch.com${map['relative_profile_img_uri']}')
    );
  }
}
class ReverbUserData {
  final int id;
  final String name;
  final Uri profileImageUrl;
  const ReverbUserData(this.id, this.name, this.profileImageUrl);

  factory ReverbUserData.fromMap(Map<String,dynamic> map) {
    debugPrint('ReverbUserData.fromMap: $map');
    return ReverbUserData(
      map['id']! as int,
      map['name']! as String,
      Uri.parse('https://polyamorymatch.com${map['relative_profile_img_uri']! as String}')
    );
  }
}
class ReverbPresenceUserData {
  final int id;
  final String name;
  const ReverbPresenceUserData(this.id, this.name);

  factory ReverbPresenceUserData.fromMap(Map<String,dynamic> map) {
    debugPrint('ReverbPresenceUserData.fromMap: $map');
    return ReverbPresenceUserData(
        map['id'] as int,
        map['name'] as String
    );
  }
}
enum ReverbGroupRole {
  member('member'),
  admin('admin');
  final String role;
  const ReverbGroupRole(this.role);

  factory ReverbGroupRole.fromString(String roleData) {
    debugPrint('ReverbGroupRole.fromString: $roleData');
    for (final event in ReverbGroupRole.values) {
      return event;
    }
    throw Exception('UnimplementedGroupRole');
  }
}
class ReverbGroupUserData {
  final int id;
  final String name;
  final ReverbGroupRole role;
  final Uri profilesImageUrl;
  const ReverbGroupUserData(
    this.id,
    this.name,
    this.role,
    this.profilesImageUrl
  );
  factory ReverbGroupUserData.fromMap(Map<String,dynamic> oldMap) {
    debugPrint('ReverbGroupUserData.fromMap: $oldMap');
    return ReverbGroupUserData(
      oldMap['id'] as int,
      oldMap['name'] as String,
      ReverbGroupRole.fromString(oldMap['role'] as String),
      Uri.parse('https://${oldMap['relative_profile_img_uri']}')
    );
  }
}
class PresenceUserMap {
  // Keys are int "strings" of user ids
  final Map<String,ReverbPresenceUserData> userMap;
  const PresenceUserMap(this.userMap);
  factory PresenceUserMap.fromMap(Map<String,dynamic> oldMap) {
    debugPrint('PresenceUserMap.fromMap: $oldMap');
    final Map<String,ReverbPresenceUserData> newMap = {};
    oldMap.forEach((userId, userInfo) {
      newMap[userId] = ReverbPresenceUserData.fromMap(userInfo);
    });
    return PresenceUserMap(newMap);
  }
}
class PresenceData {
  final PresenceUserMap hashData; // `hash`
  final int count; // `count`
  const PresenceData(this.hashData, this.count);
  factory PresenceData.fromMap(Map<String,dynamic> oldMap) {
    debugPrint('PresenceUserMap.fromMap: $oldMap');
    return PresenceData(
      PresenceUserMap.fromMap(oldMap['hash'] as Map<String,dynamic>),
      oldMap['count'] as int
    );
  }
}
class PresenceSubscriptionSucceededEventBody {
  final PresenceData presenceData; // `presence`

  const PresenceSubscriptionSucceededEventBody(this.presenceData);

  factory PresenceSubscriptionSucceededEventBody.unmarshall(String data) {
    debugPrint('PresenceSubscriptionSucceededEventBody.unmarshall: $data');
    final json = jsonDecode(data) as Map<String,dynamic>;
    return PresenceSubscriptionSucceededEventBody(
        PresenceData.fromMap(json['presence'] as Map<String,dynamic>)
    );
  }
}
class MemberAddedEventBody {
  final String userId;
  final ReverbPresenceUserData userData;

  const MemberAddedEventBody(this.userId, this.userData);
  factory MemberAddedEventBody.unmarshall(String data) {
    debugPrint('MemberAddedEventBody.unmarshall: $data');
    final Map<String,dynamic> dataMap = jsonDecode(data);
    return MemberAddedEventBody(
      dataMap['user_id'] as String,
      ReverbPresenceUserData.fromMap(dataMap['user_info'] as Map<String,dynamic>)
    );
  }
}
class MemberRemovedEventBody {
  final String userId;
  const MemberRemovedEventBody(this.userId);
  factory MemberRemovedEventBody.unmarshall(String data) {
    debugPrint('MemberRemovedEventBody.unmarshall');
    final Map<String,dynamic> dataMap = jsonDecode(data);
    return MemberRemovedEventBody(dataMap['user_id'] as String);
  }
}
class GroupCreatedEventBody {
  final GroupData groupData;
  final String message;
  final int unreadCount;
  const GroupCreatedEventBody(this.groupData, this.message, this.unreadCount);
  factory GroupCreatedEventBody.unmarshall(String data) {
    debugPrint('GroupCreatedEventBody.unmarshall');
    final dataMap = jsonDecode(data) as Map<String,dynamic>;
    return GroupCreatedEventBody(
      GroupData.fromMap(dataMap['group'] as Map<String,dynamic>),
      dataMap['message'] as String,

      // TODO: Double check field is not returned as unreadCount
      dataMap['unread_count'] as int
    );
  }
}
class ReverbChatAttachment {
  final int id;
  final String name;
  final String mime;
  final int size;
  final Uri url;
  const ReverbChatAttachment(
    this.id,
    this.name,
    this.mime,
    this.size,
    this.url
  );

  factory ReverbChatAttachment.fromMap(
    Map<String,dynamic> map
  ) {
    debugPrint('ReverbChatAttachment.fromMap: $map');
    return ReverbChatAttachment(
      map['id'] as int,
      map['name'] as String,
      map['mime'] as String,
      map['size'] as int,
      Uri.parse(map['url'])
    );
  }
}
enum ReverbMessageType {
  private('private'),
  group('group');
  final String rawValue;
  const ReverbMessageType(this.rawValue);
  factory ReverbMessageType.fromString(String rawString) {
    debugPrint('ReverbMessageType: $rawString');
    for (final value in ReverbMessageType.values) {
      if (value.rawValue == rawString) {
        return value;
      }
    }
    throw Exception('Message type unimplemented');
  }
}
class MessageBase {
  final int id;
  final String body;
  final DateTime createdAt;
  final String? humanCreatedAt;
  final ReverbMessageStatus? status;
  final ReverbUserData? user;
  final int conversationId; // `conversation_id`
  final List<ReverbChatAttachment> attachments; // `attachments`
  final ReverbMessageType messageType; // `type`
  const MessageBase(
    this.id,
    this.body,
    this.createdAt,
    this.humanCreatedAt,
    this.status,
    this.user,
    this.conversationId,
    this.attachments,
    this.messageType
  );
  factory MessageBase.fromMap(Map<String,dynamic> map) {
    debugPrint('MessageBase.fromMap: $map');

    final List<ReverbChatAttachment> attachments = [];
    if (map.containsKey('attachments') && (map['attachments'] as List).isNotEmpty) {
      for (var attachment in map['attachments'] as List<dynamic>) {
        attachments.add(
            ReverbChatAttachment.fromMap(
                attachment as Map<String, dynamic>
            )
        );
      }
    }

    return MessageBase(
      map['id'] as int,
      map['body'] as String,
      DateTime.parse(map['created_at']),
      map['human_created_at'] as String?,
      ReverbMessageStatus.fromString(map['status'] as String?),
      map.containsKey('user')
        ? ReverbUserData.fromMap(map['user'] as Map<String,dynamic>)
        : null,
      map['conversation_id'] as int,
      attachments,
      ReverbMessageType.fromString(map['type'])
    );
  }
}
enum ReverbMessageStatus {
  sent('sent'),
  delivered('delivered'),
  read('read');
  final String status;
  const ReverbMessageStatus(
    this.status
  );
  static ReverbMessageStatus? fromString(String? raw) {
    if (raw == null) return null;
    for (final status in ReverbMessageStatus.values) {
      if (status.status == raw) {
        return status;
      }
    }
    throw Exception('An unimplemented status HAS BEEN USED! ($raw)');
  }
}

class PrivateMessageSentEventBody {
  final MessageBase message; // `message`
  PrivateMessageSentEventBody(
    this.message
  );

  factory PrivateMessageSentEventBody.unmarshal(String data) {
    debugPrint('PrivateMessageSentEventBody.unmarshal: $data');
    final Map<String, dynamic> dataMap = jsonDecode(data);
    return PrivateMessageSentEventBody(
      MessageBase.fromMap(dataMap['message'])
    );
  }
}

class GroupMessageBase {
  final int id;
  final String body;
  final DateTime createdAt;
  final String? humanCreatedAt;
  final ReverbMessageStatus? status;
  final ReverbGroupUserData? user;
  final int conversationId; // `conversation_id`
  final List<ReverbChatAttachment> attachments; // `attachments`
  final ReverbMessageType messageType; // `type`
  const GroupMessageBase(
    this.id,
    this.body,
    this.createdAt,
    this.humanCreatedAt,
    this.status,
    this.user,
    this.conversationId,
    this.attachments,
    this.messageType
  );
  factory GroupMessageBase.fromMap(Map<String,dynamic> map) {
    debugPrint('MessageBase.fromMap: $map');

    final List<ReverbChatAttachment> attachments = [];
    if (map.containsKey('attachments') && (map['attachments'] as List).isNotEmpty) {
      for (var attachment in map['attachments'] as List<dynamic>) {
        attachments.add(
          ReverbChatAttachment.fromMap(
            attachment as Map<String, dynamic>
          )
        );
      }
    }

    return GroupMessageBase(
      map['id'] as int,
      map['body'] as String,
      DateTime.parse(map['created_at']),
      map['human_created_at'] as String?,
      map.containsKey('status')
        ? ReverbMessageStatus.fromString(map['status'] as String)
        : null,
      map.containsKey('user')
        ? ReverbGroupUserData.fromMap(map['user'] as Map<String,dynamic>)
        : null,
      map['conversation_id'] as int,
      attachments,
      ReverbMessageType.fromString(map['type'])
    );
  }
}


class GroupMessageSentEventBody {

 final GroupMessageBase message; // `message`

 const GroupMessageSentEventBody(
     this.message
 );

 factory GroupMessageSentEventBody.unmarshall(
   String data
 ) {
   debugPrint('GroupMessageSentEventBody.unmarshal: $data');
   final Map<String, dynamic> dataMap = jsonDecode(data);

   return GroupMessageSentEventBody(
     GroupMessageBase.fromMap(dataMap['message'])
   );
 }
}
// Sent, delivered, and read
class MessageStatusUpdateEventBody {
  final int messageId;
  const MessageStatusUpdateEventBody(this.messageId);
  factory MessageStatusUpdateEventBody.unmarshal(String data) {
    debugPrint('MessageStatusUpdateEventBody.unmarshal: $data');
    final Map<String,dynamic> dataMap = jsonDecode(data);
    return MessageStatusUpdateEventBody(dataMap['message_id']);
  }
}
class UserMatchedEventBody {
  final int matchId;
  final int conversationId;
  final ReverbUserData matchedUser;
  final String message;
  const UserMatchedEventBody(
    this.matchId,
    this.conversationId,
    this.matchedUser,
    this.message
  );
  factory UserMatchedEventBody.unmarshall(String data) {
    debugPrint('UserMatchedEventBody.unmarshall: $data');
    final Map<String,dynamic> dataMap = jsonDecode(data);
    return UserMatchedEventBody(
      dataMap['match_id'] as int,
      dataMap['conversation_id'] as int,
      ReverbUserData.fromMap(dataMap['matched_user']),
      dataMap['message'] as String
    );
  }
}
class UserTypingEventBody {
  final int userId;
  final String userName;
  const UserTypingEventBody(this.userId,this.userName);
  factory UserTypingEventBody.fromJson(String data) {
    debugPrint('UserTypingEventBody.fromJson: $data');
    final Map<String,dynamic> dataMap = jsonDecode(data);
    return UserTypingEventBody(
      dataMap['user_id'] as int,
      dataMap['user_name'] as String
    );
  }
}