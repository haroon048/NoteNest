import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _authService.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  // Login Method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during login');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Register Method
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during registration');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Logout Method
  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}
