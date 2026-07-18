// import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:swiss/core/network/dio_exception_handler.dart';

import '../../../../core/constants/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  AuthRepository({required this.dioClient});
  final TokenStorage _tokenStorage = TokenStorage();

  //register new user____________________________________________
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.register,
        data: {
          "email": email,
          'phone': phone,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName,
          'last_name': lastName,
          'user_type': 'customer',
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  //Login__________________________________
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  //Get current user______________________________________
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get(ApiConstants.currentUser);
    return UserModel.fromJson(response.data);
  }

  //Save Token after login____________________________________
  Future<void> saveAuthData(Map<String, dynamic> data) async {
    // final userData = data['user'];
    final access = data['access'];
    final refresh = data['refresh'];
    await _tokenStorage.saveToken(accessToken: access, refreshToken: refresh);
  }
}
