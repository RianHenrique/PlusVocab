import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import 'tema_resumo.dart';

class TemasService {
  final ApiClient _apiClient;
  TemasService(this._apiClient);

  Future<List<TemaResumo>> listarTemas() async {
    try {
      final response = await _apiClient.get('/themes/list');
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw 'Resposta inválida ao listar temas.';
      }
      if (body['success'] != true) {
        throw body['message']?.toString() ?? 'Não foi possível carregar os temas.';
      }
      final data = body['data'];
      if (data is! List<dynamic>) {
        throw 'Formato de lista de temas inválido.';
      }
      return data
          .map((e) => TemaResumo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar temas.';
    }
  }

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

}
