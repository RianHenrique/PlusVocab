import 'package:dio/dio.dart';
import 'package:plus_vocab/core/services/api_client.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';

class VocabPracticeService {
  VocabPracticeService(this._apiClient);

  final ApiClient _apiClient;

  Future<PracticeSessionPayload> iniciarSessao({required String themeId}) async {
    try {
      final response = await _apiClient.post(
        '/vocab/practice/start',
        data: {'themeId': themeId},
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      return PracticeSessionPayload.fromApi(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])?.toString()
          : e.response?.data?.toString();
      throw msg ?? 'Erro ao iniciar prática.';
    }
  }

  Future<void> submeterResultados(PracticeSessionOutcome outcome) async {
    try {
      await _apiClient.post(
        '/vocab/practice/${outcome.practiceSessionId}/submit',
        data: outcome.toSubmitBody(),
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])?.toString()
          : e.response?.data?.toString();
      throw msg ?? 'Erro ao enviar resultado da prática.';
    }
  }
}
