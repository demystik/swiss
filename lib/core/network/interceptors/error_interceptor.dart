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
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        return handler.next(err);
      }

      final response = await dio.post(
        ApiConstants.refresh,
        data: {"refresh": refreshToken},
      );

      final newAccessToken = response.data["access"];

      await tokenStorage.saveAccessToken(newAccessToken);

      final options = err.requestOptions;

      options.headers["Authorization"] = "Bearer $newAccessToken";

      final retryResponse = await dio.fetch(options);

      return handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clearTokens();

      return handler.next(err);
    }
  }
}
