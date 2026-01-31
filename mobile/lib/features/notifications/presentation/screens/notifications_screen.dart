import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/notification.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationState.when(
            data: (state) {
              if (state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    ref.read(notificationNotifierProvider.notifier).markAllAsRead();
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationState.when(
        data: (state) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  Text(
                    'When you receive trip requests or messages,\nthey will appear here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    // Mark as read
                    if (!notification.isRead) {
                      ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
                    }
                    // Navigate based on notification type
                    _handleNotificationTap(context, notification);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppTheme.spacingMD),
              Text(
                'Error loading notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppTheme.spacingMD),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    final data = notification.data;
    
    switch (notification.type) {
      case NotificationType.tripRequest:
      case NotificationType.requestAccepted:
      case NotificationType.requestRejected:
        // Navigate to trip details if tripId is available
        if (data != null && data['tripId'] != null) {
          context.push('/trip/${data['tripId']}');
        }
        break;
      case NotificationType.newMessage:
        // Navigate to chat if requestId is available
        if (data != null && data['requestId'] != null) {
          context.push('/chat/${data['requestId']}');
        }
        break;
      case NotificationType.tripUpdate:
        // Navigate to trip details if tripId is available
        if (data != null && data['tripId'] != null) {
          context.push('/trip/${data['tripId']}');
        }
        break;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM + 4,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? theme.colorScheme.primary.withOpacity(0.05)
              : null,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on notification type
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(theme).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(),
                size: 22,
                color: _getIconBackgroundColor(theme),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM + 4),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (isUnread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.tripRequest:
        return Icons.person_add_outlined;
      case NotificationType.requestAccepted:
        return Icons.check_circle_outlined;
      case NotificationType.requestRejected:
        return Icons.cancel_outlined;
      case NotificationType.newMessage:
        return Icons.message_outlined;
      case NotificationType.tripUpdate:
        return Icons.update_outlined;
    }
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.tripRequest:
        return theme.colorScheme.primary;
      case NotificationType.requestAccepted:
        return Colors.green;
      case NotificationType.requestRejected:
        return Colors.red;
      case NotificationType.newMessage:
        return theme.colorScheme.secondary;
      case NotificationType.tripUpdate:
        return theme.colorScheme.tertiary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
