import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceAuth {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return 'Please fill in all fields.';
    }

    try {
      // Proses pembuatan akun
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return 'Failed to create user.';
      }

      try {
        // Simpan data pengguna ke Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'uid': credential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return 'Sign Up Success';
      } on FirebaseException catch (e) {
        return 'Failed to save user data: ${e.message ?? 'Unknown Firestore error.'}';
      } catch (e) {
        return 'Unexpected error while saving user data: $e';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password is too weak.';
        case 'email-already-in-use':
          return 'The email is already in use.';
        case 'invalid-email':
          return 'The email is invalid.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return e.message ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields.';
    }

    try {
      // Proses login pengguna
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Login Success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'invalid-email':
          return 'The email is invalid.';
        default:
          return e.message ?? 'An error occurred during login.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
