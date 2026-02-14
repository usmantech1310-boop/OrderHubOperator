import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await secureStorage.write(key: 'access_token', value: token);
}

Future<String?> readToken() async {
  return await secureStorage.read(key: 'access_token');
}

Future<void> deleteToken() async {
  await secureStorage.delete(key: 'access_token');
}
