import 'package:dio/dio.dart';
import 'package:swiss/core/constants/api_constant.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/core/network/dio_exception_handler.dart';

class ProfileRepository {
  final DioClient dioClient;
  ProfileRepository({required this.dioClient});

  Future<Map<String, dynamic>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String profilePictureUrl,
  }) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.baseUrl,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'profile_picture_url': profilePictureUrl,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
