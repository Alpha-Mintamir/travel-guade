import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  @JsonValue('TRIP_REQUEST')
  tripRequest,
  @JsonValue('REQUEST_ACCEPTED')
  requestAccepted,
  @JsonValue('REQUEST_REJECTED')
  requestRejected,
  @JsonValue('NEW_MESSAGE')
  newMessage,
  @JsonValue('TRIP_UPDATE')
  tripUpdate,
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
