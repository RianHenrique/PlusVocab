// lib/core/services/api_client.dart (ou dio_client.dart)

import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:3000/api',
            connectTimeout: const Duration(seconds: 5),
            // Você pode configurar headers padrões, interceptors, etc. TUDO AQUI
          ),
        );
  
  // Você pode até adicionar métodos helper
  Future<Response> get(String path) => dio.get(path);
  Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
}