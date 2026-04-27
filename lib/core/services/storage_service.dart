import 'dart:convert';

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
  static const _keyUserEmail = 'KEY_USER_EMAIL';
  static const _keyUserProfileJson = 'KEY_USER_PROFILE_JSON';
  static const _keyThemesFromLoginJson = 'KEY_THEMES_FROM_LOGIN_JSON';
  static const _keyMostrarProximasPalavras = 'KEY_MOSTRAR_PROXIMAS_PALAVRAS';

  // --- SALVAR DADOS ---
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? userEmail,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
    if (userEmail != null && userEmail.isNotEmpty) {
      await _storage.write(key: _keyUserEmail, value: userEmail);
    }
  }

  Future<void> saveSessionPresentation({
    String? profileJson,
    String? themesFromLoginJson,
  }) async {
    if (profileJson != null) {
      await _storage.write(key: _keyUserProfileJson, value: profileJson);
    } else {
      await _storage.delete(key: _keyUserProfileJson);
    }
    if (themesFromLoginJson != null) {
      await _storage.write(key: _keyThemesFromLoginJson, value: themesFromLoginJson);
    } else {
      await _storage.delete(key: _keyThemesFromLoginJson);
    }
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

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<String?> getUserProfileJson() async {
    return await _storage.read(key: _keyUserProfileJson);
  }

  Future<String?> getThemesFromLoginJson() async {
    return await _storage.read(key: _keyThemesFromLoginJson);
  }

  Future<void> setMostrarProximasPalavras(bool value) async {
    await _storage.write(key: _keyMostrarProximasPalavras, value: value.toString());
  }

  Future<bool> getMostrarProximasPalavras() async {
    final v = await _storage.read(key: _keyMostrarProximasPalavras);
    if (v == null) return true;
    return v == 'true';
  }

  static List<Map<String, dynamic>> decodeThemesFromLoginJson(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return [];
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
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