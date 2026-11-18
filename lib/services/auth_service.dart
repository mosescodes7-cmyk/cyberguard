import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants.dart';
import '../models/user_profile.dart';

String friendlyAuthError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This phone number already has an account. Please sign in.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return 'Incorrect phone number or PIN.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your data or Wi-Fi and try again.';
      case 'weak-password':
        return 'Choose a stronger PIN.';
      case 'operation-not-allowed':
        return 'Sign-in is currently unavailable. Please contact support.';
      case 'requires-recent-login':
        return 'Please sign in again and retry.';
      default:
        return 'Something went wrong (${e.code}). Please try again.';
    }
  }
  if (e is FirebaseException) {
    return 'Service error (${e.code}). Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static String emailFor(String phone) => '$phone@${AppConfig.authDomain}';

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Stream<UserProfile?> profileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((s) {
      final data = s.data();
      return data == null ? null : UserProfile.fromMap(uid, data);
    });
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String pin,
    required String userType,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: emailFor(phone),
      password: pin,
    );
    final user = cred.user!;
    await user.updateDisplayName(name);
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'userType': userType,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn({required String phone, required String pin}) async {
    await _auth.signInWithEmailAndPassword(
      email: emailFor(phone),
      password: pin,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    final cred = EmailAuthProvider.credential(email: email, password: currentPin);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPin);
  }
}
