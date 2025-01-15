import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/services/logger_service.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/welcome_screen.dart';

enum UserType { electrician, homeowner, none }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authStateSubscription;
  late final Future<void> initializationCompleted;

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
    // Initialize the completion future
    initializationCompleted = _initializeAuth();
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
      if (_user == null) {
        _isAuthenticated = false;
        _userType = UserType.none;
        _profile = null;
        notifyListeners();
        return;
      }

      final userProfile = await _authService.getUserProfile(_user!.id);
      if (userProfile != null) {
        _userType = userProfile['type'] == 'electrician'
            ? UserType.electrician
            : UserType.homeowner;
        _profile = userProfile['profile'];
        _isAuthenticated = true;
        notifyListeners();
      } else {
        // Instead of signing out, just clear the state
        _isAuthenticated = false;
        _userType = UserType.none;
        _profile = null;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load user profile', e, stackTrace);
      // Instead of signing out, just clear the state
      _isAuthenticated = false;
      _userType = UserType.none;
      _profile = null;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password, UserType type) async {
    try {
      // First check if there's an existing session and clear it
      if (_user != null) {
        await signOut();
      }

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;

      // Load and validate profile type before setting authenticated state
      final userProfile = await _authService.getUserProfile(_user!.id);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final profileType = userProfile['type'] == 'electrician'
          ? UserType.electrician
          : UserType.homeowner;

      if (profileType != type) {
        // Clear state and throw error
        _user = null;
        throw Exception('Invalid user type');
      }

      // Set state only after validation
      _userType = profileType;
      _profile = userProfile['profile'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      // Clear all state on any error
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;
      notifyListeners();
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

  Future<void> signOutAndNavigate(BuildContext context) async {
    try {
      // First, detach the auth state listener to prevent unwanted updates
      _authStateSubscription?.pause();

      // Clear the state immediately but don't notify
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;

      // Then sign out from Supabase
      await _authService.signOut();

      // Only after state is cleared, navigate
      if (context.mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }

      // Finally notify listeners after navigation is complete
      notifyListeners();

      // Resume the auth state listener
      _authStateSubscription?.resume();
    } catch (e, stackTrace) {
      // Resume the auth state listener in case of error
      _authStateSubscription?.resume();
      LoggerService.error('Failed to sign out and navigate', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // First, detach the auth state listener to prevent unwanted updates
      _authStateSubscription?.pause();

      // Clear the state immediately but don't notify
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;

      // Delete the account
      await _authService.deleteAccount();

      // Navigate to welcome screen
      if (context.mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }

      // Finally notify listeners after navigation is complete
      notifyListeners();

      // Resume the auth state listener
      _authStateSubscription?.resume();
    } catch (e, stackTrace) {
      // Resume the auth state listener in case of error
      _authStateSubscription?.resume();
      LoggerService.error('Failed to delete account', e, stackTrace);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

// TODO: Implement account deletion functionality
