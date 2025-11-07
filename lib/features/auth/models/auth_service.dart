import '../../../core/services/api_client.dart';
import '../../../core/common_models/user_model.dart';
import 'package:dio/dio.dart';
import '../../../core/services/storage_service.dart';

class AuthService {

  final ApiClient _apiClient;
  AuthService(this._apiClient);
  final StorageService _storageService = StorageService();

  Future<User> signUp({
    required String email,
    required String password,
    required String confirmPassword

  }) async {
    try {
      final response = await _apiClient.post('/auth/signup', data: {'email': email, 'password': password, 'confirmPassword': confirmPassword});
      if (response.statusCode == 201 && response.data != null) {

        final user = User.fromJson(response.data);

        final accessToken = user.accessToken;
        final refreshToken = user.refreshToken;
        final userId = user.id;

        await _storageService.saveAuthData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );
      
        return user;

      } else {
        throw Exception('Resposta inesperada da API.');
      }
    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response?.statusCode == 409) {
          // Se for 409 (Conflito)...
          throw 'Este email já está em uso. Tente outro.';
        } else {
          // Outro erro do Dio (como 404, 500, etc.)
          String serverError = e.response?.data?['message'] ?? 'Falha na comunicação com o servidor.';
          throw serverError; // Lança a String pura
        }
      } else {
        // Erro genérico
        throw Exception('Falha ao cadastrar: $e');
      }
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {'email': email, 'password': password});

      if (response.statusCode == 202 && response.data != null) {

        final user = User.fromJson(response.data);

        final accessToken = user.accessToken;
        final refreshToken = user.refreshToken;
        final userId = user.id;

        await _storageService.saveAuthData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );
      
        return user;

      } else if (response.statusCode == 200 && response.data != null) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Resposta inesperada da API.');
      }
    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response?.statusCode == 401) {
          // Se for 401 (Não autorizado)...
          throw 'Email ou senha inválidos.';
        } else {
          // Outro erro do Dio (como 404, 500, etc.)
          String serverError = e.response?.data?['message'] ?? 'Falha na comunicação com o servidor.';
          throw serverError; // Lança a String pura
        }
      } else {
        // Erro genérico
        throw Exception('Falha ao logar: $e');
      }
    }
  }
}