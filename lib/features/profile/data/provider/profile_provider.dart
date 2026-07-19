import 'package:flutter/material.dart';
import 'package:swiss/features/auth/data/models/user_model.dart';
import 'package:swiss/features/profile/data/repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileProvider(this.repository);

  bool _isLoading = false;
  String? _error;
  UserModel? _updatedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get updatedUser => _updatedUser;

  Future<UserModel?> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? phone,
    String? profilePictureUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _updatedUser = await repository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        phone: phone,
        profilePictureUrl: profilePictureUrl,
      );

      _isLoading = false;
      notifyListeners();
      return _updatedUser;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
