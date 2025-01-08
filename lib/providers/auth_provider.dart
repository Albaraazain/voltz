import 'package:flutter/foundation.dart';

enum UserType { electrician, homeowner, none }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.none;
  String? _userId;
  String? _email;
  String? _fullName;

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  String? get userId => _userId;
  String? get email => _email;
  String? get fullName => _fullName;

  Future<void> signIn(String email, String password, UserType type) async {
    try {
      // Mock authentication - In real app, this would be a server call
      await Future.delayed(const Duration(seconds: 1));
      _isAuthenticated = true;
      _userType = type;
      _email = email;
      _userId = 'mock_user_id'; // In real app, this would come from server
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _userType = UserType.none;
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, UserType type,
      {String? fullName}) async {
    try {
      // Mock registration - In real app, this would be a server call
      await Future.delayed(const Duration(seconds: 1));
      _isAuthenticated = true;
      _userType = type;
      _email = email;
      _fullName = fullName;
      _userId = 'mock_user_id'; // In real app, this would come from server
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _userType = UserType.none;
      rethrow;
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _userType = UserType.none;
    _userId = null;
    _email = null;
    _fullName = null;
    notifyListeners();
  }
}
