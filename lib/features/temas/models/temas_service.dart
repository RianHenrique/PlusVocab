import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';

class TemasService {
  final ApiClient _apiClient;
  TemasService(this._apiClient);

  Future<Map<String, dynamic>> criarTema({
    required String nome,
    required String descricao,
    required List<String> modalidades,
  }) async {
    try {
      final response = await _apiClient.post('/themes/create', data: {
        'name': nome,
        'description': descricao,
        'modalities': modalidades,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data?['error'] ?? 'Erro ao criar tema.';
    }
  }

  Future<Map<String, dynamic>> iniciarPratica({
    required String themeId,
  }) async {
    try {
      final response = await _apiClient.post('/vocab/practice/start', data: {
        'themeId': themeId,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? 'Erro ao iniciar prática.';
    }
  }
}
