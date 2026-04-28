import 'package:dio/dio.dart';
import 'package:plus_vocab/core/services/api_client.dart';
import 'package:plus_vocab/features/progress/models/progress_modalities_models.dart';
import 'package:plus_vocab/features/progress/models/progress_overview_models.dart';
import 'package:plus_vocab/features/progress/models/progress_themes_models.dart';
import 'package:plus_vocab/features/progress/models/ranking_week_models.dart';

class ProgressService {
  ProgressService(this._apiClient);

  final ApiClient _apiClient;

  Future<ProgressOverview> fetchOverview() async {
    try {
      final response = await _apiClient.get('/progress/overview');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return ProgressOverview.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar visão geral do progresso.';
    }
  }

  Future<ProgressWeeklyBundle> fetchWeekly({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/progress/weekly',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return ProgressWeeklyBundle.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar dados semanais.';
    }
  }

  Future<ModalitiesResponse> fetchModalities({
    required String startDate,
    required String endDate,
    int? modalityId,
  }) async {
    try {
      final query = <String, dynamic>{
        'startDate': startDate,
        'endDate': endDate,
      };
      if (modalityId != null) {
        query['modalityId'] = modalityId;
      }
      final response = await _apiClient.get('/progress/modalities', queryParameters: query);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return ModalitiesResponse.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar modalidades.';
    }
  }

  Future<ThemesResponse> fetchThemes({
    required String startDate,
    required String endDate,
    String? themeId,
  }) async {
    try {
      final query = <String, dynamic>{
        'startDate': startDate,
        'endDate': endDate,
      };
      if (themeId != null && themeId.isNotEmpty) {
        query['themeId'] = themeId;
      }
      final response = await _apiClient.get('/progress/themes', queryParameters: query);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return ThemesResponse.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar temas.';
    }
  }

  Future<RankingWeekResponse> fetchRankingWeek() async {
    try {
      final response = await _apiClient.get('/progress/rankingWeek');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Formato de resposta inválido.';
      }
      return RankingWeekResponse.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'Erro ao carregar ranking da semana.';
    }
  }
}
