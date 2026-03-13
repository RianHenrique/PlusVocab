import '../../../core/services/api_client.dart';
import '../../../core/common_models/user_model.dart';
import 'package:dio/dio.dart';
import '../../../core/services/storage_service.dart';

class AuthService {

  final ApiClient _apiClient;
  final StorageService _storageService;
  AuthService(this._apiClient, this._storageService);
  // final StorageService _storageService = StorageService();

  StorageService get storage => _storageService;

  Future<bool> refreshAcessToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    final userId = await _storageService.getUserId();

    try {
      final response = await _apiClient.post('/auth/refresh', data: {'refreshToken': refreshToken});

      final newAccessToken = response.data['accessToken'];

      await _storageService.saveAuthData(
        accessToken: newAccessToken,
        refreshToken: refreshToken!,
        userId: userId!,
      );

      return true;

    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response?.statusCode == 401) {
          throw 'Refresh inválido ou expirado';
        } else {
          // Outro erro do Dio (como 404, 500, etc.)
          String serverError = e.response?.data?['message'] ?? 'Falha na comunicação com o servidor.';
          throw serverError; // Lança a String pura
        }
      } else {
        // Erro genérico
        throw Exception('Falha ao validar acesso: $e');
      }
    }
  }

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

  Future<bool> sendRecoveryEmail({required String email}) async {
    try {
      final response = await _apiClient.post('/auth/forgot-password', data: {'email': email});

      if (response.statusCode == 200 && response.data != null) {
        return true;
      } else {
        throw Exception('Não foi possível processar a solicitação de recuperação.');
      }

    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response == null){
          // debugPrint('Tipo de Erro Dio: ${e.type}');
          // debugPrint('Mensagem: ${e.message}');
          if (e.type == DioExceptionType.connectionTimeout) {
            throw 'O servidor demorou demais para responder.';
          } else {
            throw 'Não foi possível conectar ao servidor. Verifique sua internet.';
          }
        } else if (e.response?.statusCode == 401) {
          // Se for 401 (Não autorizado)...
          throw 'E-mail não cadastrado no sistema.';
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

  Future<String> sendRecoveryCode({required String email, required String code}) async {
    try {
      final response = await _apiClient.post('/auth/forgot-password/verify', data: {'email': email, 'code': code});

      if (response.statusCode == 200 && response.data != null) {
        return response.data['resetToken']; // Supondo que a API retorne um token de recuperação
      } else {
        throw Exception('Não foi possível processar a solicitação de recuperação.');
      }

    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response == null){
          // debugPrint('Tipo de Erro Dio: ${e.type}');
          // debugPrint('Mensagem: ${e.message}');
          if (e.type == DioExceptionType.connectionTimeout) {
            throw 'O servidor demorou demais para responder.';
          } else {
            throw 'Não foi possível conectar ao servidor. Verifique sua internet.';
          }
        } else if (e.response?.statusCode == 401) {
          // Se for 401 (Não autorizado)...
          throw 'E-mail não cadastrado no sistema.';
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

  Future<void> resetPassword({required String email, required String resetToken, required String newPassword}) async {
    try {
      final response = await _apiClient.post('/auth/forgot-password/reset', data: {'email': email, 'resetToken': resetToken, 'newPassword': newPassword});

      if (response.statusCode == 200 && response.data != null) {
        // TODO: Talvez queira retornar algo ou apenas considerar o processo concluído
      } else {
        throw Exception('Não foi possível processar a solicitação de recuperação.');
      }

    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response == null){
          // debugPrint('Tipo de Erro Dio: ${e.type}');
          // debugPrint('Mensagem: ${e.message}');
          if (e.type == DioExceptionType.connectionTimeout) {
            throw 'O servidor demorou demais para responder.';
          } else {
            throw 'Não foi possível conectar ao servidor. Verifique sua internet.';
          }
        } else if (e.response?.statusCode == 401) {
          // Se for 401 (Não autorizado)...
          throw 'E-mail não cadastrado no sistema.';
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

  Future<void> logOut() async {
    final refreshToken = await _storageService.getRefreshToken();
    try {
      await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
      await _storageService.clearAuthData();
    } catch (e) {
      if (e is DioException) {
        if (e.response == null){
          if (e.type == DioExceptionType.connectionTimeout) {
            throw 'O servidor demorou demais para responder.';
          } else {
            throw 'Não foi possível conectar ao servidor. Verifique sua internet.';
          }
        } else if (e.response?.statusCode == 401) {
          throw 'Token de acesso inválido.';
        } else {
          String serverError = e.response?.data?['message'] ?? 'Falha na comunicação com o servidor.';
          throw serverError;
        }
      } else {
        throw Exception('Ocorreu algum erro: $e');
      }
    }
  }
}