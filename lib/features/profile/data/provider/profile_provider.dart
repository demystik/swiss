import 'package:flutter/material.dart';
import 'package:swiss/features/profile/data/repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider(this._profileRepository);

  Future<void> profileUpdate({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String profilePictureUrl,
  }) async {
    try {
      final data = await _profileRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        profilePictureUrl: profilePictureUrl,
      );
    } catch (e) {}
  }
}
