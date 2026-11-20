import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokens;
  final Dio _plainDio; // Dio sans intercepteur, pour refresh et rejeu
  final void Function() _onSessionExpired;
  AuthInterceptor(this._tokens, this._plainDio, this._onSessionExpired);

  bool _isAuthPath(RequestOptions o) => o.path.startsWith('/auth/');

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.access;
    if (token != null && !_isAuthPath(options) ||
        options.path == '/auth/me' && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    if (err.response?.statusCode != 401 || req.path == '/auth/refresh' ||
        req.path == '/auth/login') {
      return handler.next(err);
    }
    final refresh = await _tokens.refresh;
    if (refresh == null) {
      _onSessionExpired();
      return handler.next(err);
    }
    try {
      final res = await _plainDio
          .post('/auth/refresh', data: {'refresh_token': refresh});
      final access = res.data['access_token'] as String;
      final newRefresh = res.data['refresh_token'] as String? ?? refresh;
      await _tokens.save(access, newRefresh);
      req.headers['Authorization'] = 'Bearer $access';
      handler.resolve(await _plainDio.fetch(req));
    } on DioException {
      await _tokens.clear();
      _onSessionExpired();
      handler.next(err);
    }
  }
}