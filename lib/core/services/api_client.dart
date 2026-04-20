// lib/core/services/api_client.dart (ou dio_client.dart)

import 'package:dio/dio.dart';
import './api_middleware.dart';
import 'package:plus_vocab/features/auth/models/auth_service.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://plusvocab-api.onrender.com/api',
            connectTimeout: const Duration(seconds: 5),
            // Você pode configurar headers padrões, interceptors, etc. TUDO AQUI
          ),
        );
  
  void addAuthInterceptor(AuthService authService) {
    dio.interceptors.add(AuthInterceptor(dio, authService));
  }
  
  // Você pode até adicionar métodos helper
  Future<Response> get(String path) => dio.get(path);
  Future<Response> post(String path, {dynamic data, Options? options}) =>
      dio.post(path, data: data, options: options);
}