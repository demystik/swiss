import 'package:flutter/material.dart';
import '../auth/data/repository/auth_repository.dart';
import '../auth/data/models/user_model.dart';
import '../../core/storage/token_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    try {
      final data = await _repository.register(
        email: email,
        phone: phone,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
      );

      await _repository.saveAuthData(data);
      _currentUser = UserModel.fromJson(data['user']);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final data = await _repository.login(email: email, password: password);
      await _repository.saveAuthData(data);
      _currentUser = UserModel.fromJson(data['user']);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    try {
      _currentUser = await _repository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Token might be expired
      await logout();
    }
  }

  Future<void> logout() async {
    await TokenStorage().clearTokens();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
