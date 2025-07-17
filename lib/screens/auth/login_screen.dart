import 'package:flutter/material.dart';
import 'package:people_management/components/custom_button.dart';
import 'package:people_management/components/custom_text_field.dart';
import 'package:people_management/screens/auth/register_screen.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:people_management/utils/user_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _toastMessage(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _toastMessage("Email dan kata sandi harus diisi!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await UserPreferences.saveUser(userCredential.user);
      }

      if (!mounted) return;
      _toastMessage("Login Berhasil!", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e.code == 'invalid-credential') {
        errorMessage = "Email atau kata sandi salah.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      } else if (e.code == 'channel-error') {
        errorMessage = "Silakan isi email dan kata sandi.";
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
                      'Welcome Back',
                      style: AppStyles.headingStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter your details below to log back into\nyour account',
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
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _rememberMe = newValue ?? false;
                                  });
                                },
                                activeColor: AppColors.checkboxColor,
                                checkColor: Colors.white,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: AppStyles.rememberMeStyle,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            _toastMessage(
                              "Please contact admin to reset your password!",
                              Colors.red,
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: AppStyles.linkTextStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        )
                        : CustomButton(
                          text: "Login",
                          onPressed: _login,
                          backgroundColor: AppColors.primaryPurple,
                          textColor: AppColors.cardColor,
                        ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppStyles.subHeadingStyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Replace the toast message with navigation
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
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
