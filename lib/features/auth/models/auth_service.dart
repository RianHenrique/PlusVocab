import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/common_models/user_model.dart';
import '../../../core/common_models/user_profile.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../temas/models/tema_resumo.dart';
import 'authenticated_session.dart';

class AuthService {

  final ApiClient _apiClient;
  final StorageService _storageService;
  AuthService(this._apiClient, this._storageService);
  // final StorageService _storageService = StorageService();

  StorageService get storage => _storageService;

  AuthenticatedSession _sessionFromAuthEnvelope(Map<String, dynamic> body) {
    final user = User.fromJson(body);
    UserProfile? profile;
    final themes = <TemaResumo>[];
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final rawProfile = data['profile'];
      if (rawProfile is Map<String, dynamic>) {
        profile = UserProfile.fromJson(rawProfile);
      }
      final rawThemes = data['themes'];
      if (rawThemes is List<dynamic>) {
        for (final item in rawThemes) {
          if (item is Map) {
            themes.add(TemaResumo.fromLoginSummary(Map<String, dynamic>.from(item)));
          }
        }
      }
    }
    return AuthenticatedSession(user: user, profile: profile, themesFromLogin: themes);
  }

  Future<void> _persistAuthenticatedSession(AuthenticatedSession session) async {
    await _storageService.saveAuthData(
      accessToken: session.user.accessToken,
      refreshToken: session.user.refreshToken,
      userId: session.user.id,
      userEmail: session.user.email,
    );
    final profileJson =
        session.profile != null ? jsonEncode(session.profile!.toJson()) : null;
    final themesJson = session.themesFromLogin.isNotEmpty
        ? jsonEncode(
            session.themesFromLogin.map((t) => {'id': t.id, 'name': t.name}).toList(),
          )
        : null;
    await _storageService.saveSessionPresentation(
      profileJson: profileJson,
      themesFromLoginJson: themesJson,
    );
  }

  Future<bool> refreshAcessToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    final userId = await _storageService.getUserId();

    if (refreshToken == null || userId == null) {
      throw 'Sessão expirada. Faça login novamente.';
    }

    try {
      final response = await _apiClient.post('/auth/refresh', data: {'refreshToken': refreshToken});

      final newAccessToken = response.data['accessToken'];

      await _storageService.saveAuthData(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
        userId: userId,
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
          userEmail: user.email,
        );
        await _storageService.saveSessionPresentation(
          profileJson: null,
          themesFromLoginJson: null,
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

  Future<AuthenticatedSession> signIn({required String email, required String password}) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {'email': email, 'password': password});

      if ((response.statusCode == 200 || response.statusCode == 202) && response.data != null) {
        final session = _sessionFromAuthEnvelope(response.data as Map<String, dynamic>);
        await _persistAuthenticatedSession(session);
        return session;
      }
      throw Exception('Resposta inesperada da API.');
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

  Future<AuthenticatedSession> authGoogle({
    required String serverAuthCode
  }) async {

    try {
      final response = await _apiClient.post('/auth/google', data: {'code': serverAuthCode});

      final raw = response.data;
      if (raw is! Map) {
        throw Exception('Resposta inválida do login com Google.');
      }
      final userData = Map<String, dynamic>.from(raw);

      User user = User(
        id: userData['profile']['id'],
        email: userData['profile']['email'],
        accessToken: userData['accessToken'],
        refreshToken: userData['refreshToken']
      );

      await _storageService.saveAuthData(
        accessToken: userData['accessToken'],
        refreshToken: userData['refreshToken'],
        userId: userData['profile']['id'],
        userEmail: userData['profile']['email'] as String?,
      );

      AuthenticatedSession googleSession;
      try {
        googleSession = _sessionFromAuthEnvelope(userData);
      } catch (_) {
        googleSession = AuthenticatedSession(user: user);
      }
      await _persistAuthenticatedSession(googleSession);

      return googleSession;

    } catch (e) {
      if (e is DioException) {
        // Verifica se a exceção é do Dio
        if (e.response?.statusCode == 401) {
          throw 'Falha na autorização com o Google. Tente novamente.';
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

  Future<void> logOut() async {
    final refreshToken = await _storageService.getRefreshToken();
    try {
      await _apiClient.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      // if (e is DioException) {
      //   if (e.response == null){
      //     if (e.type == DioExceptionType.connectionTimeout) {
      //       throw 'O servidor demorou demais para responder.';
      //     } else {
      //       throw 'Não foi possível conectar ao servidor. Verifique sua internet.';
      //     }
      //   } else if (e.response?.statusCode == 401) {
      //     throw 'Token de acesso inválido.';
      //   } else {
      //     String serverError = e.response?.data?['message'] ?? 'Falha na comunicação com o servidor.';
      //     throw serverError;
      //   }
      debugPrint('Aviso de logout ao servidor falhou: $e');
      // } else {
      //   throw Exception('Ocorreu algum erro: $e');
      // }
    } finally {
      await _storageService.clearAuthData();
    }
  }
}