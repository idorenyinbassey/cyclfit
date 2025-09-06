import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AppDatabase _database;
  final FlutterSecureStorage _storage;

  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider({
    required AppDatabase database,
    required FlutterSecureStorage storage,
  }) : _database = database,
       _storage = storage {
    _initializeAuth();
    _listenToAuthChanges();
  }

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      _currentUser = Supabase.instance.client.auth.currentUser;
      if (_currentUser != null) {
        await _loadUserProfile();
      } else {
        await _tryAutoSignIn();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _tryAutoSignIn() async {
    try {
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');
      if (email != null && password != null) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        _currentUser = Supabase.instance.client.auth.currentUser;
        if (_currentUser != null) {
          await _loadUserProfile();
          notifyListeners();
        }
      }
    } catch (_) {
      // Ignore auto sign-in errors
    }
  }

  void _listenToAuthChanges() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final session = data.session;
      _currentUser = session?.user;
      if (_currentUser != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // Email and password sign in
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        await _storeCredentials(email, password);
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email and password sign up
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _createUserProfile(name, email);
        await _storeCredentials(email, password);
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Sign up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In (TODO: Implement when Google Sign-In is properly configured)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement Google Sign-In
      // This requires proper platform configuration
      _setError('Google Sign-In not yet implemented');
      return false;
    } catch (e) {
      _setError('Google sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await Supabase.instance.client.auth.signOut();
      await _clearStoredCredentials();
      _currentUser = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // You may customize the redirectTo URL in Supabase Auth settings
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final query = _database.select(_database.userProfiles)
        ..where((tbl) => tbl.userId.equals(_currentUser!.id));
      final profile = await query.getSingleOrNull();

      if (profile != null) {
        _userProfile = UserModel.fromDatabase(profile);
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile(String name, String email) async {
    if (_currentUser == null) return;

    try {
      final profile = UserProfilesCompanion.insert(
        userId: _currentUser!.id,
        email: email,
        name: name,
      );

      await _database.into(_database.userProfiles).insert(profile);
      await _loadUserProfile();
    } catch (e) {
      debugPrint('Failed to create user profile: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedProfile) async {
    _setLoading(true);
    _clearError();

    try {
      final updateQuery = _database.update(_database.userProfiles)
        ..where((tbl) => tbl.userId.equals(_currentUser!.id));
      await updateQuery.write(
        UserProfilesCompanion(
          name: Value(updatedProfile.name),
          age: Value(updatedProfile.age),
          weight: Value(updatedProfile.weight),
          height: Value(updatedProfile.height),
          fitnessLevel: Value(updatedProfile.fitnessLevel),
          profileImageUrl: Value(updatedProfile.profileImageUrl),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await _loadUserProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Store credentials securely
  Future<void> _storeCredentials(String email, String password) async {
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
  }

  // Clear stored credentials
  Future<void> _clearStoredCredentials() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
