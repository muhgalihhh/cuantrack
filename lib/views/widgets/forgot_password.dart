import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          myDialogBox(context);
        },
        child: const Text('Forgot Password?'),
      ),
    );
  }

  void myDialogBox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  top: 100,
                  bottom: 16,
                  left: 32,
                  right: 32,
                ),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Please enter your email address. You will receive a link to create a new password via email.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                        labelText: 'Email Address',
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () async {
                          String email = emailController.text.trim();

                          // Validasi apakah email kosong
                          if (email.isEmpty) {
                            _showSnackBar(context,
                                'Please enter an email address.', Colors.red);
                            return;
                          }

                          // Validasi format email
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                          if (!emailRegex.hasMatch(email)) {
                            _showSnackBar(
                                context,
                                'Please enter a valid email address.',
                                Colors.red);
                            return;
                          }

                          // Menampilkan loader selama proses berlangsung
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // Mengirim email untuk reset password
                            await auth.sendPasswordResetEmail(email: email);

                            // Jika berhasil
                            Navigator.of(context).pop(); // Menutup loader
                            _showSnackBar(
                                context,
                                'Check your email for the reset link.',
                                colorScheme.primary);
                            Navigator.of(context).pop(); // Menutup dialog
                          } on FirebaseAuthException catch (error) {
                            Navigator.of(context).pop(); // Menutup loader
                            if (error.code == 'user-not-found') {
                              _showSnackBar(
                                  context,
                                  'No user found for that email address.',
                                  Colors.red);
                            } else {
                              _showSnackBar(
                                  context,
                                  error.message ??
                                      'An unexpected error occurred.',
                                  Colors.red);
                            }
                          } catch (error) {
                            Navigator.of(context).pop(); // Menutup loader
                            _showSnackBar(
                                context,
                                'An error occurred: ${error.toString()}',
                                Colors.red);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  radius: 50,
                  child: Icon(
                    Icons.lock,
                    color: colorScheme.background,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function untuk menampilkan SnackBar
  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
