import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/trip_request.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/providers.dart';

part 'chat_provider.g.dart';

/// Provider for conversations (accepted requests)
@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<Conversation>> build() async {
    return ref.read(apiServiceProvider).getConversations();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Update unread count for a conversation
  void markAsRead(String requestId) {
    final currentConversations = state.valueOrNull;
    if (currentConversations != null) {
      state = AsyncValue.data(
        currentConversations.map((c) {
          if (c.id == requestId) {
            return c.copyWith(unreadCount: 0);
          }
          return c;
        }).toList(),
      );
    }
  }

  /// Update last message for a conversation
  void updateLastMessage(String requestId, Message message) {
    final currentConversations = state.valueOrNull;
    if (currentConversations != null) {
      state = AsyncValue.data(
        currentConversations.map((c) {
          if (c.id == requestId) {
            return c.copyWith(
              lastMessage: message,
              unreadCount: c.unreadCount + 1,
            );
          }
          return c;
        }).toList(),
      );
    }
  }
}

/// State class for chat messages
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? typingUserId;
  final bool isSending;

  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.typingUserId,
    this.isSending = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? typingUserId,
    bool clearTyping = false,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      typingUserId: clearTyping ? null : (typingUserId ?? this.typingUserId),
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Provider for messages in a specific conversation
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  Timer? _typingDebounce;
  bool _listenersSetup = false;

  @override
  Future<ChatState> build(String requestId) async {
    // Clean up on dispose - remove socket listeners and leave conversation
    ref.onDispose(() {
      _cleanupSocketListeners();
      _typingDebounce?.cancel();
      _leaveConversation();
    });

    // Fetch initial messages
    final response = await ref.read(apiServiceProvider).getMessages(
      requestId: requestId,
      page: 1,
    );

    // Join conversation room and set up socket listeners
    _joinConversation();
    _setupSocketListeners();

    return ChatState(
      messages: response.messages,
      hasMore: response.pagination.page < response.pagination.totalPages,
      currentPage: 1,
    );
  }

  void _joinConversation() {
    final socket = ref.read(socketServiceProvider);
    socket.emit('join_conversation', {'requestId': requestId});
  }

  void _leaveConversation() {
    final socket = ref.read(socketServiceProvider);
    socket.emit('leave_conversation', {'requestId': requestId});
  }

  void _setupSocketListeners() {
    // Prevent duplicate listeners
    if (_listenersSetup) return;
    _listenersSetup = true;

    final socket = ref.read(socketServiceProvider);

    // Listen for new messages
    socket.on('message_received', _onMessageReceived);

    // Listen for typing indicators
    socket.on('user_typing', _onUserTyping);
    socket.on('user_stopped_typing', _onUserStoppedTyping);

    // Listen for read receipts
    socket.on('message_read', _onMessageRead);
  }

  void _cleanupSocketListeners() {
    if (!_listenersSetup) return;
    _listenersSetup = false;

    final socket = ref.read(socketServiceProvider);
    socket.off('message_received');
    socket.off('user_typing');
    socket.off('user_stopped_typing');
    socket.off('message_read');
  }

  void _onMessageReceived(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return;
    try {
      final message = Message.fromJson(data);
      _addMessage(message);
      
      // Also update conversations list
      ref.read(conversationsNotifierProvider.notifier)
          .updateLastMessage(requestId, message);
    } catch (e) {
      // Handle parsing errors gracefully
    }
  }

  void _onUserTyping(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return;
    final userId = data['userId'];
    if (userId is String) {
      _setTypingUser(userId);
    }
  }

  void _onUserStoppedTyping(dynamic data) {
    _clearTypingUser();
  }

  void _onMessageRead(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return;
    final messageId = data['messageId'];
    if (messageId is String) {
      _markMessageAsRead(messageId);
    }
  }

  void _addMessage(Message message) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      // Check if message already exists (to avoid duplicates)
      if (!currentState.messages.any((m) => m.id == message.id)) {
        state = AsyncValue.data(currentState.copyWith(
          messages: [...currentState.messages, message],
        ));
      }
    }
  }

  void _setTypingUser(String userId) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(typingUserId: userId));
    }
  }

  void _clearTypingUser() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(clearTyping: true));
    }
  }

  void _markMessageAsRead(String messageId) {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        messages: currentState.messages.map((m) {
          if (m.id == messageId) {
            return m.copyWith(isRead: true);
          }
          return m;
        }).toList(),
      ));
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoading || !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await ref.read(apiServiceProvider).getMessages(
        requestId: requestId,
        page: nextPage,
      );

      state = AsyncValue.data(currentState.copyWith(
        messages: [...response.messages, ...currentState.messages],
        isLoading: false,
        hasMore: response.pagination.page < response.pagination.totalPages,
        currentPage: nextPage,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Send a message
  void sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final socket = ref.read(socketServiceProvider);
    socket.emit('send_message', {
      'requestId': requestId,
      'content': content.trim(),
    });

    // Stop typing indicator
    stopTyping();

    // The message will be added when we receive it back from the server
    // via the message_received socket event
  }

  /// Start typing indicator
  void startTyping() {
    final socket = ref.read(socketServiceProvider);
    socket.emit('typing_start', {'requestId': requestId});

    // Auto-stop typing after 3 seconds of no input
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 3), () {
      stopTyping();
    });
  }

  /// Stop typing indicator
  void stopTyping() {
    _typingDebounce?.cancel();
    final socket = ref.read(socketServiceProvider);
    socket.emit('typing_stop', {'requestId': requestId});
  }

  /// Mark a message as read
  void markRead(String messageId) {
    final socket = ref.read(socketServiceProvider);
    socket.emit('mark_read', {'messageId': messageId});
  }

  /// Mark all unread messages as read
  void markAllAsRead(String currentUserId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    for (final message in currentState.messages) {
      if (!message.isRead && message.receiverId == currentUserId) {
        markRead(message.id);
      }
    }

    // Update conversations unread count
    ref.read(conversationsNotifierProvider.notifier).markAsRead(requestId);
  }
}

/// Provider to get total unread message count
@riverpod
int totalUnreadCount(TotalUnreadCountRef ref) {
  final conversations = ref.watch(conversationsNotifierProvider);
  return conversations.maybeWhen(
    data: (convos) => convos.fold(0, (sum, c) => sum + c.unreadCount),
    orElse: () => 0,
  );
}

/// Provider to get the other user in a conversation
@riverpod
User? conversationOtherUser(
  ConversationOtherUserRef ref,
  Conversation conversation,
  String currentUserId,
) {
  if (conversation.requesterId == currentUserId) {
    // Current user is the requester, other user is trip creator
    return conversation.trip?.creator;
  } else {
    // Current user is trip creator, other user is requester
    return conversation.requester;
  }
}
