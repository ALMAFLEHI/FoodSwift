import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register with email and password
  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      rethrow;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
