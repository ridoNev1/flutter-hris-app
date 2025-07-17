import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:people_management/components/custom_button.dart';
import 'package:people_management/components/custom_text_field.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserFormScreen extends StatefulWidget {
  final Users? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  final List<String> _roles = ['Admin', 'User'];
  String? _selectedRole;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();

    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _avatarUrlController.text = widget.user!.avatarUrl ?? '';
      _selectedRole = widget.user!.role;
    } else {
      _selectedRole = 'User';
    }
  }

  Future<void> _loadCurrentUserRole() async {
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _currentUserRole = doc.data()?['role'];
          });
        }
      } catch (e) {
        _toastMessage("Gagal memuat data peran: $e", Colors.red);
      }
    }
  }

  void _toastMessage(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }

  Future<void> _saveUser() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedRole == null) {
      _toastMessage("Nama, Email, dan Role harus diisi!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': _selectedRole,
      'avatarUrl': _avatarUrlController.text.trim(),
    };

    try {
      if (widget.user == null) {
        await _firestore.collection('users').add(userData);
        _toastMessage("Pengguna baru berhasil ditambahkan", Colors.green);
      } else {
        await _firestore
            .collection('users')
            .doc(widget.user!.id)
            .update(userData);
        _toastMessage("Data pengguna berhasil diperbarui", Colors.blue);
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserListScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _toastMessage("Gagal menyimpan data: $e", Colors.red);
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
    _nameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.user != null;
    final bool isRoleSelectionDisabled = _currentUserRole != 'Admin';

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Pengguna' : 'Tambah Pengguna Baru',
          style: AppStyles.buttonTextStyle,
        ),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.cardColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                backgroundImage:
                    _avatarUrlController.text.isNotEmpty
                        ? NetworkImage(_avatarUrlController.text)
                        : null,
                child:
                    _avatarUrlController.text.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primaryPurple.withOpacity(0.7),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _nameController,
              hintText: 'Nama Lengkap',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColors.hintColor,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.hintColor,
              ),
            ),
            const SizedBox(height: 20),
            AbsorbPointer(
              absorbing: isRoleSelectionDisabled,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isRoleSelectionDisabled
                          ? Colors.grey.shade200
                          : AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    hint: Text('Pilih Role', style: AppStyles.subHeadingStyle),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.hintColor,
                    ),
                    style: AppStyles.inputTextStyle,
                    onChanged:
                        isRoleSelectionDisabled
                            ? null
                            : (String? newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                    items:
                        _roles.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _avatarUrlController,
              hintText: 'URL Gambar Profil (Opsional)',
              prefixIcon: const Icon(
                Icons.image_outlined,
                color: AppColors.hintColor,
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                  text: isEditing ? 'Simpan Perubahan' : 'Tambah Pengguna',
                  onPressed: _saveUser,
                  backgroundColor: AppColors.primaryPurple,
                  textColor: AppColors.cardColor,
                ),
          ],
        ),
      ),
    );
  }
}
