import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    // Disconnect existing socket if any
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }

    _socket = IO.io(
      ApiConstants.baseUrl.replaceAll('/api', ''),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket?.onConnect((_) {
      print('Socket connected');
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket?.onError((error) {
      print('Socket error: $error');
    });

    _socket?.onConnectError((error) {
      print('Socket connection error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      print('Socket not connected, cannot emit: $event');
      return;
    }
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  // Chat-specific methods

  /// Join a conversation room to receive messages
  void joinConversation(String requestId) {
    emit('join_conversation', {'requestId': requestId});
  }

  /// Leave a conversation room
  void leaveConversation(String requestId) {
    emit('leave_conversation', {'requestId': requestId});
  }

  /// Send a message in a conversation
  void sendMessage(String requestId, String content) {
    emit('send_message', {
      'requestId': requestId,
      'content': content,
    });
  }

  /// Start typing indicator
  void startTyping(String requestId) {
    emit('typing_start', {'requestId': requestId});
  }

  /// Stop typing indicator
  void stopTyping(String requestId) {
    emit('typing_stop', {'requestId': requestId});
  }

  /// Mark a message as read
  void markMessageRead(String messageId) {
    emit('mark_read', {'messageId': messageId});
  }

  // Event listeners for chat

  /// Listen for new messages
  void onMessageReceived(Function(Map<String, dynamic>) callback) {
    on('message_received', (data) {
      callback(data as Map<String, dynamic>);
    });
  }

  /// Listen for user typing
  void onUserTyping(Function(String requestId, String userId) callback) {
    on('user_typing', (data) {
      final map = data as Map<String, dynamic>;
      callback(map['requestId'] as String, map['userId'] as String);
    });
  }

  /// Listen for user stopped typing
  void onUserStoppedTyping(Function(String requestId, String userId) callback) {
    on('user_stopped_typing', (data) {
      final map = data as Map<String, dynamic>;
      callback(map['requestId'] as String, map['userId'] as String);
    });
  }

  /// Listen for message read receipt
  void onMessageRead(Function(String messageId) callback) {
    on('message_read', (data) {
      final map = data as Map<String, dynamic>;
      callback(map['messageId'] as String);
    });
  }

  /// Listen for conversation joined confirmation
  void onJoinedConversation(Function(String requestId) callback) {
    on('joined_conversation', (data) {
      final map = data as Map<String, dynamic>;
      callback(map['requestId'] as String);
    });
  }

  /// Listen for errors
  void onSocketError(Function(String message) callback) {
    on('error', (data) {
      final map = data as Map<String, dynamic>;
      callback(map['message'] as String);
    });
  }

  // Notification events

  /// Join user's personal notification room
  void joinNotificationRoom(String userId) {
    emit('join_notification_room', {'userId': userId});
  }

  /// Listen for new notifications
  void onNotification(Function(Map<String, dynamic>) callback) {
    on('notification', (data) {
      callback(data as Map<String, dynamic>);
    });
  }
}
