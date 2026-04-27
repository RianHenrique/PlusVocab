import 'package:dio/dio.dart';

import '../../../core/common_models/user_profile.dart';
import '../../../core/services/api_client.dart';

class UserAccountPayload {
  const UserAccountPayload({
    required this.userId,
    required this.email,
    this.profile,
  });

  final String userId;
  final String email;
  final UserProfile? profile;
}

class UserService {
  UserService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserAccountPayload> fetchUserById(String userId) async {
    try {
      final response = await _apiClient.get('/user/$userId');
      final body = response.data;
      if (body is! Map<String, dynamic>) throw 'Resposta inválida ao carregar usuário.';
      if (body['success'] != true) {
        throw body['message']?.toString() ?? 'Não foi possível carregar o usuário.';
      }
      final data = body['data'];
      if (data is! Map<String, dynamic>) throw 'Formato de dados inválido.';
      final user = data['user'];
      if (user is! Map) throw 'Dados de usuário ausentes.';
      final userMap = Map<String, dynamic>.from(user);
      final id = userMap['id'] as String;
      final email = userMap['email'] as String? ?? '';
      UserProfile? profile;
      final rawProfile = userMap['profile'];
      if (rawProfile is Map) {
        profile = UserProfile.fromJson(Map<String, dynamic>.from(rawProfile));
      }
      return UserAccountPayload(userId: id, email: email, profile: profile);
    } on DioException catch (e) {
      throw e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          'Erro ao carregar dados do usuário.';
    }
  }

  Future<UserProfile> updateProfile(String userId, Map<String, dynamic> fields) async {
    if (fields.isEmpty) {
      throw 'Nenhum campo para atualizar.';
    }
    try {
      final response = await _apiClient.post('/user/$userId', data: fields);
      final body = response.data;
      if (body is! Map<String, dynamic>) throw 'Resposta inválida ao atualizar perfil.';
      if (body['success'] != true) {
        throw body['message']?.toString() ?? 'Não foi possível atualizar o perfil.';
      }
      final data = body['data'];
      if (data is! Map<String, dynamic>) throw 'Formato de resposta inválido.';
      final rawProfile = data['profile'];
      if (rawProfile is! Map) throw 'Perfil não retornado pela API.';
      return UserProfile.fromJson(Map<String, dynamic>.from(rawProfile));
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      if (msg != null && msg.isNotEmpty) throw msg;
      final errors = e.response?.data?['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['msg'] != null) throw first['msg'].toString();
      }
      throw e.response?.data?['error']?.toString() ?? 'Erro ao atualizar perfil.';
    }
  }
}
