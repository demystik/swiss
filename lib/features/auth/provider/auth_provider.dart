import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swiss/core/network/api_exceptions.dart';
import '../data/repository/auth_repository.dart';
import '../data/models/user_model.dart';
import '../../../core/storage/token_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.checking;

  AuthProvider(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthStatus get status => _status;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

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
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (_) {
      _error = "something went wrong";
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
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      if (e is DioException) {
        // print("******************************************************");
        // print(e.response?.statusCode);
        // print(e.response?.data);
      }
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    try {
      final token = await TokenStorage().getAccessToken();

      if (token == null) {
        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return;
      }

      _currentUser = await _repository.getCurrentUser();

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      await logout();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStorage().clearTokens();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

enum AuthStatus { checking, authenticated, unauthenticated }
