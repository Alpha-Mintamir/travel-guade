import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/providers.dart';
import '../../../shared/services/storage_service.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    final token = await ref.read(secureStorageProvider).read(key: 'token');
    if (token == null) return null;
    try {
      final user = await ref.read(apiServiceProvider).getCurrentUser();
      // Connect socket when user is authenticated
      await _connectSocket();
      return user;
    } catch (e) {
      // Token invalid, clear it
      await StorageService.deleteToken();
      return null;
    }
  }

  Future<void> _connectSocket() async {
    final socketService = ref.read(socketServiceProvider);
    await socketService.connect();
  }

  void _disconnectSocket() {
    final socketService = ref.read(socketServiceProvider);
    socketService.disconnect();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiServiceProvider).login(email, password);
      await StorageService.saveToken(response.token);
      // Connect socket after successful login
      await _connectSocket();
      return response.user;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiServiceProvider).register(
            email: email,
            password: password,
            fullName: fullName,
            gender: gender,
            dateOfBirth: dateOfBirth,
          );
      await StorageService.saveToken(response.token);
      // Connect socket after successful registration
      await _connectSocket();
      return response.user;
    });
  }

  Future<void> logout() async {
    // Disconnect socket before logout
    _disconnectSocket();
    await StorageService.deleteToken();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    String? fullName,
    String? cityOfResidence,
    String? bio,
    String? travelPreferences,
    String? interests,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(apiServiceProvider).updateProfile(
            fullName: fullName,
            cityOfResidence: cityOfResidence,
            bio: bio,
            travelPreferences: travelPreferences,
            interests: interests,
            gender: gender,
            dateOfBirth: dateOfBirth,
          );
    });
  }

  /// Request password reset email
  Future<void> forgotPassword(String email) async {
    await ref.read(apiServiceProvider).forgotPassword(email);
  }

  /// Reset password with token from email
  Future<void> resetPassword(String token, String newPassword) async {
    await ref.read(apiServiceProvider).resetPassword(token, newPassword);
  }

  /// Verify email with token from email
  Future<void> verifyEmail(String token) async {
    await ref.read(apiServiceProvider).verifyEmail(token);
  }

  bool get isAuthenticated => state.valueOrNull != null;
}
