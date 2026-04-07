import 'package:dio/dio.dart';
import 'package:plus_vocab/features/auth/models/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthService _authService;

  AuthInterceptor(this._dio, this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    const publicRoutes = ['/auth/login', '/auth/signup', '/auth/refresh', '/auth/google'];

    if (publicRoutes.contains(options.path)) {
      return handler.next(options); // Segue viagem sem mexer em nada
    }

    // 1. Antes de cada requisição, pega o token do storage
    final token = await _authService.storage.getAccessToken();
    
    // 2. Adiciona o token no Header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') || 
        path.contains('/auth/google') || 
        path.contains('/auth/logout') ||
        path.contains('/auth/refresh')) {
      return handler.next(err); 
    }
    // 3. Verifica se o erro foi 401 (Token expirado)
    if (err.response?.statusCode == 401) {
      try {
        // 4. Tenta renovar o token
        final success = await _authService.refreshAcessToken();

        if (success) {
          // 5. Se renovou, refaz a requisição original que falhou
          final token = await _authService.storage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          // Cria uma nova chamada com as mesmas opções
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        // Se o refresh também falhar (Refresh Token venceu), desloga o usuário
        _authService.logOut();
      }
    }
    return handler.next(err);
  }
}