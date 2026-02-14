import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/mock_auth_repository.dart';

final authRepositoryProvider = Provider((ref) => MockAuthRepository());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
      (ref) => AuthController(ref.read(authRepositoryProvider)),
    );

class AuthController extends StateNotifier<AsyncValue<void>> {
  final MockAuthRepository repository;

  AuthController(this.repository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await repository.login(email, password);
      state = const AsyncData(null);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AsyncData(null);
  }

  Future<bool> isTokenValid() async {
    return await repository.isTokenValid();
  }
}
