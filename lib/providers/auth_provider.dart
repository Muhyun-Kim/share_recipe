import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(null) {
    _auth.authStateChanges().listen((User? user) {
      state = user;
    });
  }
  User? get user => state;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential credential = await _auth.signInWithProvider(
        googleProvider,
      );
      state = credential.user;
    } catch (e) {
      print("Google 로그인 오류: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
