import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/trip_request.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsNotifierProvider);
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chat),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsNotifierProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ConversationTile(
                  conversation: conversation,
                  currentUserId: currentUser?.id ?? '',
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
              Text('Error loading conversations'),
              const SizedBox(height: AppTheme.spacingMD),
              ElevatedButton(
                onPressed: () => ref.invalidate(conversationsNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: Text(
              'When your trip requests are accepted, you can chat with travel partners here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the other user in the conversation
    final bool isRequester = conversation.requesterId == currentUserId;
    final otherUser = isRequester 
        ? conversation.trip?.creator 
        : conversation.requester;
    
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: otherUser?.profilePhotoUrl != null
                ? CachedNetworkImageProvider(otherUser!.profilePhotoUrl!)
                : null,
            backgroundColor: AppColors.softTeal,
            child: otherUser?.profilePhotoUrl == null
                ? Text(
                    otherUser?.fullName.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.warmCoral,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  conversation.unreadCount > 9 
                      ? '9+' 
                      : '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUser?.fullName ?? 'Unknown User',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessage != null)
            Text(
              _formatTime(lastMessage.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasUnread 
                        ? AppColors.warmCoral 
                        : AppColors.textSecondary,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            conversation.trip?.destinationName ?? 'Trip',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (lastMessage != null)
            Text(
              _getMessagePreview(lastMessage, currentUserId),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasUnread 
                        ? Theme.of(context).colorScheme.onSurface 
                        : AppColors.textSecondary,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
      onTap: () => context.push('/chat/${conversation.id}'),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _getMessagePreview(Message message, String currentUserId) {
    final isMe = message.senderId == currentUserId;
    final prefix = isMe ? 'You: ' : '';
    return '$prefix${message.content}';
  }
}
