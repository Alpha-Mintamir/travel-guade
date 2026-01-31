import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/trip_request.dart';
import '../../../../shared/models/user.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId; // This is the requestId

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when scrolled to top (since messages are in chronological order)
    if (_scrollController.position.pixels <= 100) {
      ref.read(messagesNotifierProvider(widget.conversationId).notifier).loadMore();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(messagesNotifierProvider(widget.conversationId).notifier)
        .sendMessage(content);
    _messageController.clear();
    
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTyping(String value) {
    if (value.isNotEmpty) {
      ref.read(messagesNotifierProvider(widget.conversationId).notifier)
          .startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatStateAsync = ref.watch(messagesNotifierProvider(widget.conversationId));
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final conversations = ref.watch(conversationsNotifierProvider).valueOrNull ?? [];
    
    // Find the conversation to get other user info
    final conversation = conversations.cast<Conversation?>().firstWhere(
      (c) => c?.id == widget.conversationId,
      orElse: () => null,
    );

    // Determine the other user
    User? otherUser;
    if (conversation != null && currentUser != null) {
      final isRequester = conversation.requesterId == currentUser.id;
      otherUser = isRequester ? conversation.trip?.creator : conversation.requester;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: otherUser?.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(otherUser!.profilePhotoUrl!)
                  : null,
              backgroundColor: AppColors.softTeal,
              child: otherUser?.profilePhotoUrl == null
                  ? Text(
                      otherUser?.fullName.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser?.fullName ?? 'Chat',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation?.trip != null)
                    Text(
                      conversation!.trip!.destinationName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: chatStateAsync.when(
        data: (chatState) {
          // Mark messages as read when viewing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (currentUser != null) {
              ref.read(messagesNotifierProvider(widget.conversationId).notifier)
                  .markAllAsRead(currentUser.id);
            }
          });

          return Column(
            children: [
              // Messages list
              Expanded(
                child: chatState.messages.isEmpty
                    ? _buildEmptyMessages(context)
                    : _buildMessagesList(chatState, currentUser?.id ?? ''),
              ),
              
              // Typing indicator
              if (chatState.typingUserId != null)
                _buildTypingIndicator(otherUser?.fullName ?? 'User'),
              
              // Input area
              _buildInputArea(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppTheme.spacingMD),
              Text('Error loading messages'),
              const SizedBox(height: AppTheme.spacingMD),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                    messagesNotifierProvider(widget.conversationId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMessages(BuildContext context) {
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
            'No messages yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            'Start the conversation!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatState chatState, String currentUserId) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the top
        if (chatState.isLoading && index == 0) {
          return const Padding(
            padding: EdgeInsets.all(AppTheme.spacingMD),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final messageIndex = chatState.isLoading ? index - 1 : index;
        final message = chatState.messages[messageIndex];
        final isMe = message.senderId == currentUserId;
        
        // Check if we should show date header
        final showDateHeader = messageIndex == 0 ||
            !_isSameDay(
              chatState.messages[messageIndex - 1].createdAt,
              message.createdAt,
            );

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(message.createdAt),
            _MessageBubble(
              message: message,
              isMe: isMe,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String dateText;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      dateText = 'Today';
    } else if (diff.inDays == 1) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildTypingIndicator(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            child: _TypingDots(),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Text(
            '$userName is typing...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingMD,
        right: AppTheme.spacingSM,
        top: AppTheme.spacingSM,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              onChanged: _onTyping,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: message.sender?.profilePhotoUrl != null
                  ? CachedNetworkImageProvider(message.sender!.profilePhotoUrl!)
                  : null,
              backgroundColor: AppColors.softTeal,
              child: message.sender?.profilePhotoUrl == null
                  ? Text(
                      message.sender?.fullName.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spacingSM),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.warmCoral
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isMe ? Colors.white : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isMe
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue[200]
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 28 + AppTheme.spacingSM),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
              ),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -4 * animation.value),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
