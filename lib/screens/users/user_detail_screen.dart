import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:people_management/screens/users/user_form_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final Users user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  String? _currentUserRole;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _currentUserId = firebaseUser.uid;
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUserId)
              .get();
      if (doc.exists && mounted) {
        setState(() {
          _currentUserRole = doc.data()?['role'];
        });
      }
    }
  }

  Future<void> _deleteUser() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Anda yakin ingin menghapus user "${widget.user.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text(widget.user.name, style: AppStyles.buttonTextStyle),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.cardColor),
        actions: [
          if (_currentUserRole == 'Admin' || _currentUserId == widget.user.id)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.cardColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserFormScreen(user: widget.user),
                  ),
                );
              },
            ),
          if (_currentUserRole == 'Admin')
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: AppColors.cardColor,
              ),
              onPressed: _deleteUser,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                    backgroundImage:
                        widget.user.avatarUrl != null
                            ? NetworkImage(widget.user.avatarUrl!)
                            : null,
                    child:
                        widget.user.avatarUrl == null
                            ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primaryPurple.withOpacity(0.7),
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nama:',
                  style: AppStyles.subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.user.name,
                  style: AppStyles.inputTextStyle.copyWith(fontSize: 18),
                ),
                const Divider(height: 30),
                Text(
                  'Email:',
                  style: AppStyles.subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.user.email,
                  style: AppStyles.inputTextStyle.copyWith(fontSize: 18),
                ),
                const Divider(height: 30),
                Text(
                  'Role:',
                  style: AppStyles.subHeadingStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.user.role,
                  style: AppStyles.inputTextStyle.copyWith(
                    fontSize: 18,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
