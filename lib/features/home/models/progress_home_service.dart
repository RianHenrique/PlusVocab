import 'package:dio/dio.dart';
import 'package:plus_vocab/core/services/api_client.dart';
import 'package:plus_vocab/features/home/models/progress_home.dart';

class ProgressHomeService {
  ProgressHomeService(this._apiClient);

  final ApiClient _apiClient;

  Future<ProgressHome> fetchHome() async {
    try {
      final response = await _apiClient.get('/progress/home');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return ProgressHome.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar progresso.';
    }
  }
}
