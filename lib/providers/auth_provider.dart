import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/services/logger_service.dart';

enum UserType { electrician, homeowner, none }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authStateSubscription;

  bool _isAuthenticated = false;
  UserType _userType = UserType.none;
  User? _user;
  Map<String, dynamic>? _profile;

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  String? get userId => _user?.id;
  String? get email => _user?.email;
  String? get fullName => _profile?['name'];

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      _authStateSubscription =
          _authService.authStateChanges.listen((event) async {
        if (event.event == AuthChangeEvent.signedIn) {
          _user = event.session?.user;
          await _loadUserProfile();
        } else if (event.event == AuthChangeEvent.signedOut) {
          _isAuthenticated = false;
          _userType = UserType.none;
          _user = null;
          _profile = null;
          notifyListeners();
        }
      });

      // Check if user is already signed in
      _user = _authService.currentUser;
      if (_user != null) {
        await _loadUserProfile();
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize auth', e, stackTrace);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_user == null) return;

      final userProfile = await _authService.getUserProfile(_user!.id);
      if (userProfile != null) {
        _userType = userProfile['type'] == 'electrician'
            ? UserType.electrician
            : UserType.homeowner;
        _profile = userProfile['profile'];
        _isAuthenticated = true;
        notifyListeners();
      } else {
        await signOut();
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load user profile', e, stackTrace);
      await signOut();
    }
  }

  Future<void> signIn(String email, String password, UserType type) async {
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;
      await _loadUserProfile();

      if (_userType != type) {
        await signOut();
        throw Exception('Invalid user type');
      }
    } catch (e) {
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, UserType type,
      {String? fullName}) async {
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        name: fullName ?? email.split('@')[0],
        isElectrician: type == UserType.electrician,
      );

      _user = response.user;
      await _loadUserProfile();
    } catch (e) {
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign out', e, stackTrace);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
