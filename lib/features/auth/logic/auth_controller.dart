import 'package:flutter/material.dart';

import '../data/models/user_account.dart';
import '../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  UserAccount? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserAccount? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _repository.login(email.trim(), password);
      if (user == null) {
        _error = 'Invalid email or password.';
        return false;
      }
      _currentUser = user;
      return true;
    } catch (e) {
      _error = 'Unable to sign in. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _currentUser = user;
      return true;
    } on ArgumentError catch (e) {
      _error = e.message as String?;
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
