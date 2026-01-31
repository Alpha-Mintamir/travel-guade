import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/notification.dart';
import '../../../shared/services/providers.dart';

part 'notification_provider.g.dart';

/// Notification state class
class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  bool _listenerSetup = false;

  @override
  Future<NotificationState> build() async {
    // Clean up socket listener on dispose
    ref.onDispose(() {
      _cleanupSocketListener();
    });

    // Initialize socket listener when provider is first accessed
    _setupSocketListener();
    
    // Fetch initial notifications
    try {
      final notifications = await ref.read(apiServiceProvider).getNotifications();
      return NotificationState(notifications: notifications);
    } catch (e) {
      return NotificationState(error: e.toString());
    }
  }

  void _setupSocketListener() {
    // Prevent duplicate listeners
    if (_listenerSetup) return;
    _listenerSetup = true;

    final socketService = ref.read(socketServiceProvider);
    
    // Listen for real-time notifications
    socketService.on('notification', _onNotification);
  }

  void _cleanupSocketListener() {
    if (!_listenerSetup) return;
    _listenerSetup = false;

    final socketService = ref.read(socketServiceProvider);
    socketService.off('notification');
  }

  void _onNotification(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return;
    try {
      final notification = AppNotification.fromJson(data);
      _addNotification(notification);
    } catch (e) {
      // Log parsing errors in debug mode for easier debugging
      assert(() {
        print('Failed to parse notification: $e');
        return true;
      }());
    }
  }

  void _addNotification(AppNotification notification) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      // Add new notification to the beginning of the list
      state = AsyncValue.data(currentState.copyWith(
        notifications: [notification, ...currentState.notifications],
      ));
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await ref.read(apiServiceProvider).getNotifications();
      state = AsyncValue.data(NotificationState(notifications: notifications));
    } catch (e) {
      state = AsyncValue.data(NotificationState(error: e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(notifications: updatedNotifications));

    try {
      await ref.read(apiServiceProvider).markNotificationAsRead(notificationId);
    } catch (e) {
      // Rollback on error
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      return AppNotification(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();

    state = AsyncValue.data(currentState.copyWith(notifications: updatedNotifications));

    try {
      await ref.read(apiServiceProvider).markAllNotificationsAsRead();
    } catch (e) {
      // Rollback on error
      state = AsyncValue.data(currentState);
    }
  }
}

/// Provider for unread notification count (for badge display)
@riverpod
int unreadNotificationCount(UnreadNotificationCountRef ref) {
  final notificationState = ref.watch(notificationNotifierProvider);
  return notificationState.valueOrNull?.unreadCount ?? 0;
}
