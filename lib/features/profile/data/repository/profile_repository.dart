import 'package:dio/dio.dart';
import 'package:swiss/core/constants/api_constant.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/core/network/dio_exception_handler.dart';
import 'package:swiss/features/auth/data/models/user_model.dart';

class ProfileRepository {
  final DioClient dioClient;
  ProfileRepository({required this.dioClient});

  Future<UserModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? profilePictureUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if(firstName != null) data['first_name'] = firstName;
      if(lastName != null) data['last_name'] = lastName;
      if(middleName != null) data['middle_name'] = middleName;
      if(phone != null) data['phone'] = phone;
      if(profilePictureUrl != null) data['profile_picture_url'] = profilePictureUrl;

      final response = await dioClient.dio.patch(
        ApiConstants.updateUserProfile,
        data: {data},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
