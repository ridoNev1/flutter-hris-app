// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:people_management/components/custom_button.dart';
import 'package:people_management/components/custom_text_field.dart';
import 'package:people_management/screens//auth/login_screen.dart'; // Import login screen to navigate back
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _toastMessage(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _toastMessage("Semua kolom harus diisi!", Colors.red);
      return;
    }

    if (password != confirmPassword) {
      _toastMessage("Kata sandi tidak cocok!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      _toastMessage("Registrasi Berhasil!", Colors.green);
      // Navigate to login screen after successful registration
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = "Kata sandi terlalu lemah.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email sudah terdaftar.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      } else {
        errorMessage = "Terjadi kesalahan: ${e.message}";
      }
      _toastMessage(errorMessage, Colors.red);
    } catch (e) {
      if (!mounted) return;
      _toastMessage("Terjadi kesalahan tidak terduga.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/assets/images/login-page-background.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: double.infinity,
              padding: const EdgeInsets.all(28.0),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('lib/assets/images/logo-app.png', height: 40),
                    const SizedBox(height: 30),
                    Text(
                      'Create an Account',
                      style: AppStyles.headingStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your details below to create your\nnew account',
                      style: AppStyles.subHeadingStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.hintColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryPurple,
                          )
                        : CustomButton(
                            text: "Sign Up",
                            onPressed: _register,
                            backgroundColor: AppColors.primaryPurple,
                            textColor: AppColors.cardColor,
                          ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: AppStyles.subHeadingStyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Login',
                            style: AppStyles.linkTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}