import 'package:orderhub_operator/features/orders/data/secure_storage.dart';

class MockAuthRepository {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mocked authentication
    if (email == "test@test.com" && password == "123456") {
      final token = "mocked_access_token_123";

      await saveToken(token);

      return token;
    } else {
      throw Exception("Invalid credentials");
    }
  }

  Future<void> logout() async {
    await deleteToken();
  }

  Future<bool> isTokenValid() async {
    final token = await readToken();

    return token != null;
  }
}
