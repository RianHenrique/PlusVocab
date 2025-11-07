import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Cria a instância com configurações recomendadas para Android
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // CRUCIAL para Android moderno
    ),
  );

  // Chaves para identificar os valores
  static const _keyAccessToken = 'KEY_ACCESS_TOKEN';
  static const _keyRefreshToken = 'KEY_REFRESH_TOKEN';
  static const _keyUserId = 'KEY_USER_ID';

  // --- SALVAR DADOS ---
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
  }

  // --- LER DADOS ---
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }
  
  // Verifica se tem um token salvo (para auto-login)
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // --- LIMPAR DADOS (LOGOUT) ---
  Future<void> clearAuthData() async {
    await _storage.deleteAll();
  }
}