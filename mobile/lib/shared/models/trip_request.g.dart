// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripRequestImpl _$$TripRequestImplFromJson(Map<String, dynamic> json) =>
    _$TripRequestImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      requesterId: json['requesterId'] as String,
      message: json['message'] as String?,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      trip: json['trip'] == null
          ? null
          : Trip.fromJson(json['trip'] as Map<String, dynamic>),
      requester: json['requester'] == null
          ? null
          : User.fromJson(json['requester'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TripRequestImplToJson(_$TripRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'requesterId': instance.requesterId,
      'message': instance.message,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'trip': instance.trip?.toJson(),
      'requester': instance.requester?.toJson(),
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'PENDING',
  RequestStatus.accepted: 'ACCEPTED',
  RequestStatus.rejected: 'REJECTED',
  RequestStatus.cancelled: 'CANCELLED',
};

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      requesterId: json['requesterId'] as String,
      message: json['message'] as String?,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      trip: json['trip'] == null
          ? null
          : Trip.fromJson(json['trip'] as Map<String, dynamic>),
      requester: json['requester'] == null
          ? null
          : User.fromJson(json['requester'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'requesterId': instance.requesterId,
      'message': instance.message,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'trip': instance.trip?.toJson(),
      'requester': instance.requester?.toJson(),
      'unreadCount': instance.unreadCount,
      'lastMessage': instance.lastMessage?.toJson(),
    };

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      tripRequestId: json['tripRequestId'] as String,
      content: json['content'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] == null
          ? null
          : User.fromJson(json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'tripRequestId': instance.tripRequestId,
      'content': instance.content,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'sender': instance.sender?.toJson(),
    };
