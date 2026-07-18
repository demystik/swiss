import 'dart:io';
import 'package:dio/dio.dart';
import 'package:swiss/core/network/api_exceptions.dart';

class DioExceptionHandler {
  static ApiException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection timed out. Please try again.");
      case DioExceptionType.sendTimeout:
        return ApiException("Request took too long.");
      case DioExceptionType.receiveTimeout:
        return ApiException("Server took too long to respond.");
      case DioExceptionType.connectionError:
        return ApiException("No internet connection.");
      case DioExceptionType.badCertificate:
        return ApiException("Secure connection failed.");
      case DioExceptionType.cancel:
        return ApiException("Request cancelled.");
      case DioExceptionType.transformTimeout:
        return ApiException("Time out!");
      case DioExceptionType.badResponse:
        return _handleStatusCode(e.response?.statusCode, e.response?.data);
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return ApiException("No Internet Connection");
        }
        return ApiException("Something went wrong");
    }
  }

  static ApiException _handleStatusCode(int? code, dynamic data) {
    switch (code) {
      case 400:
        return ApiException(_extractMessage(data));
      case 401:
        return ApiException("Incorrect email or password.");

      case 403:
        return ApiException("Access denied.");

      case 404:
        return ApiException("Service unavailable.");

      case 409:
        return ApiException("This account already exists.");

      case 422:
        return ApiException(_extractMessage(data));

      case 500:
        return ApiException(
          "Our server is currently unavailable. Please try again later.",
        );
      default:
        return ApiException("Something went wrong.");
    }
  }

  static String _extractMessage(dynamic data) {
    if (data is Map) {
      if (data["detail"] != null) {
        return data["detail"];
      }

      if (data["message"] != null) {
        return data["message"];
      }

      if (data["error"] != null) {
        return data["error"];
      }
    }

    return "Something went wrong.";
  }
}
