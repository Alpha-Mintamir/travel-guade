import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class SocketService {
  IO.Socket? _socket;

  IO.Socket? get socket => _socket;

  Future<void> connect() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    _socket = IO.io(
      ApiConstants.baseUrl.replaceAll('/api', ''),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
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
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
