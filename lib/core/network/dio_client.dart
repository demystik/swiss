import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:swiss/core/network/interceptors/auth_interceptor.dart';
import 'package:swiss/core/network/interceptors/error_interceptor.dart';
import 'package:swiss/core/storage/token_storage.dart';
import '../constants/api_constant.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    final tokenStorage = TokenStorage();

    dio.interceptors.add(AuthInterceptor(tokenStorage));

    dio.interceptors.add(
      ErrorInterceptor(dio: dio, tokenStorage: tokenStorage),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }
}
