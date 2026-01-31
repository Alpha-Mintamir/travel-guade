import 'package:freezed_annotation/freezed_annotation.dart';
import 'trip.dart';
import 'user.dart';

part 'trip_request.freezed.dart';
part 'trip_request.g.dart';

enum RequestStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
}

@freezed
class TripRequest with _$TripRequest {
  const factory TripRequest({
    required String id,
    required String tripId,
    required String requesterId,
    String? message,
    required RequestStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    Trip? trip,
    User? requester,
  }) = _TripRequest;

  factory TripRequest.fromJson(Map<String, dynamic> json) =>
      _$TripRequestFromJson(json);
}

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String tripId,
    required String requesterId,
    String? message,
    required RequestStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    Trip? trip,
    User? requester,
    @Default(0) int unreadCount,
    Message? lastMessage,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String senderId,
    required String receiverId,
    required String tripRequestId,
    required String content,
    @Default(false) bool isRead,
    required DateTime createdAt,
    User? sender,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
