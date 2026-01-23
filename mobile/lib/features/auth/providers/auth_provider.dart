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
      return await ref.read(apiServiceProvider).getCurrentUser();
    } catch (e) {
      // Token invalid, clear it
      await StorageService.deleteToken();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiServiceProvider).login(email, password);
      await StorageService.saveToken(response.token);
      return response.user;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiServiceProvider).register(
            email: email,
            password: password,
            fullName: fullName,
          );
      await StorageService.saveToken(response.token);
      return response.user;
    });
  }

  Future<void> logout() async {
    await StorageService.deleteToken();
    state = const AsyncData(null);
  }

  bool get isAuthenticated => state.valueOrNull != null;
}
