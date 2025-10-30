import '../../../core/services/api_client.dart';
import '../../../core/common_models/user_model.dart';
import 'package:dio/dio.dart';

class AuthService {

  final ApiClient _apiClient;
  AuthService(this._apiClient);

  Future<User> signUp({
    required String email,
    required String password,
    required String confirmPassword

  }) async {
    try {
      final response = await _apiClient.post('/auth/signup', data: {'email': email, 'password': password, 'confirmPassword': confirmPassword});
      if (response.statusCode == 201 && response.data != null) {
        return User.fromJson(response.data);
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
}