import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _authSub = _service.authChanges.listen(_onUser);
  }

  final AuthService _service;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  User? user;
  UserProfile? profile;
  bool initialized = false;

  bool get isSignedIn => user != null;
  String get uid => user?.uid ?? '';

  String get displayName {
    final n = profile?.name ?? user?.displayName ?? '';
    return n.trim().isEmpty ? 'there' : n.trim();
  }

  String get phone {
    if (profile != null && profile!.phone.isNotEmpty) return profile!.phone;
    final email = user?.email ?? '';
    return email.contains('@') ? email.split('@').first : '';
  }

  String get userType => profile?.userType ?? 'Resident';

  bool get isAdmin => profile?.role == 'admin';

  void _onUser(User? u) {
    user = u;
    profile = null;
    _profileSub?.cancel();
    if (u != null) {
      _profileSub = _service.profileStream(u.uid).listen((p) {
        profile = p;
        notifyListeners();
      }, onError: (_) {});
    }
    initialized = true;
    notifyListeners();
  }

  /// Each method returns an error message, or null on success.
  Future<String?> signIn(String phone, String pin) async {
    try {
      await _service.signIn(phone: phone, pin: pin);
      return null;
    } catch (e) {
      return friendlyAuthError(e);
    }
  }

  Future<String?> signUp({
    required String name,
    required String phone,
    required String pin,
    required String userType,
  }) async {
    try {
      await _service.signUp(
          name: name, phone: phone, pin: pin, userType: userType);
      return null;
    } catch (e) {
      return friendlyAuthError(e);
    }
  }

  Future<String?> changePin(String currentPin, String newPin) async {
    try {
      await _service.changePin(currentPin: currentPin, newPin: newPin);
      return null;
    } catch (e) {
      return friendlyAuthError(e);
    }
  }

  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
