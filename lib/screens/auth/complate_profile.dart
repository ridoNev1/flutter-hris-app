import 'package:flutter/material.dart';
import 'package:people_management/components/custom_button.dart';
import 'package:people_management/components/custom_text_field.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteRegisterScreen extends StatefulWidget {
  const CompleteRegisterScreen({super.key});

  @override
  State<CompleteRegisterScreen> createState() => _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _saveProfile() async {
    String fullName = _fullNameController.text.trim();
    String profile = _profileController.text.trim();

    if (fullName.isEmpty) {
      _toastMessage("Nama lengkap harus diisi!", Colors.red);
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _toastMessage(
        "Sesi pengguna tidak ditemukan, silakan login kembali.",
        Colors.red,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserListScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'name': fullName,
        'avatarUrl': profile,
        'email': currentUser.email,
        'createdAt': Timestamp.now(),
        'role': 'User',
      });

      if (!mounted) return;
      _toastMessage("Profil berhasil disimpan!", Colors.green);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserListScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _toastMessage("Gagal menyimpan profil: ${e.toString()}", Colors.red);
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
    _fullNameController.dispose();
    _profileController.dispose();
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
                      'Complete Your Profile',
                      style: AppStyles.headingStyle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lengkapi detail profil Anda untuk melanjutkan',
                      style: AppStyles.subHeadingStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: _fullNameController,
                      hintText: 'Nama Lengkap',
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _profileController,
                      hintText: 'URL Gambar Profil (Opsional)',
                      prefixIcon: const Icon(
                        Icons.image_outlined,
                        color: AppColors.hintColor,
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        )
                        : CustomButton(
                          text: "Save and Continue",
                          onPressed: _saveProfile,
                          backgroundColor: AppColors.primaryPurple,
                          textColor: AppColors.cardColor,
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
