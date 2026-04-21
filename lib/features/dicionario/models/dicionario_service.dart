import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import 'palavra_model.dart';

class DicionarioService {
  final ApiClient _apiClient;
  DicionarioService(this._apiClient);

  Future<List<PalavraModel>> listarPalavras() async {
    try {
      final response = await _apiClient.get('/vocab/dificuldades');
      final data = response.data;
      if (data is! List) throw 'Formato de resposta inválido.';
      return data.map((e) => PalavraModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Erro ao carregar palavras.';
    }
  }

  Future<({PalavraModel palavra, bool reativada})> adicionarPalavra(String word) async {
    try {
      final response = await _apiClient.post('/vocab/adicionar', data: {'word': word});
      return (
        palavra: PalavraModel.fromJson(response.data['userWordDifficulty'] as Map<String, dynamic>),
        reativada: response.data['reactivated'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Erro ao adicionar palavra.';
    }
  }

  Future<void> removerPalavra(String id) async {
    try {
      await _apiClient.delete('/vocab/dificuldades/$id');
    } on DioException catch (e) {
      throw e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Erro ao remover palavra.';
    }
  }
}
