import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter untuk mendapatkan current user
  User? get currentUser => _auth.currentUser;

  // Getter untuk stream status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in with Google
  bool isSignedInWithGoogle() {
    if (currentUser == null) return false;

    return currentUser!.providerData
        .any((provider) => provider.providerId == 'google.com');
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure no user is currently signed in
      await signOut();

      // Begin interactive sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google Sign In was cancelled by user';
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw 'Failed to sign in with Google: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Check if signed in with Google
      if (isSignedInWithGoogle()) {
        await _googleSignIn.signOut();
      }

      // Always sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Handle Firebase Auth Errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'This account exists with different sign in provider';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'operation-not-allowed':
        return 'Google sign in is not enabled';
      case 'user-disabled':
        return 'User has been disabled';
      case 'user-not-found':
        return 'No user found';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      default:
        return 'An unknown error occurred';
    }
  }
}
