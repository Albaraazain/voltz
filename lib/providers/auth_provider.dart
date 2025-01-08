import 'package:flutter/foundation.dart';

enum UserType { electrician, homeowner, none }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.none;

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;

  Future<void> signIn(String email, String password, UserType type) async {
    // Mock authentication
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userType = type;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, UserType type) async {
    // Mock registration
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userType = type;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _userType = UserType.none;
    notifyListeners();
  }
}
