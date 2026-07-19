import 'package:dio/dio.dart';
import '../../constants/api_constant.dart';
import '../../storage/token_storage.dart';

class ErrorInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;

  ErrorInterceptor({required this.dio, required this.tokenStorage});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    // Ignore every error except 401
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't refresh Login/Register/Refresh requests
    if (request.path.contains(ApiConstants.login) ||
        request.path.contains(ApiConstants.register) ||
        request.path.contains(ApiConstants.refresh)) {
      return handler.next(err);
    }

    // Only refresh authenticated requests
    if (!request.headers.containsKey("Authorization")) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }

    try {
      // Use a fresh Dio instance to avoid recursive interceptors
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final refreshResponse = await refreshDio.post(
        ApiConstants.refresh,
        data: {"refresh": refreshToken},
      );

      final newAccessToken = refreshResponse.data["access"];

      // Save new token
      await tokenStorage.saveAccessToken(newAccessToken);

      // Update Authorization header
      request.headers["Authorization"] = "Bearer $newAccessToken";

      // Retry original request
      final response = await dio.fetch(request);

      return handler.resolve(response);
    } catch (_) {
      await tokenStorage.clearTokens();

      return handler.next(err);
    }
  }
}
