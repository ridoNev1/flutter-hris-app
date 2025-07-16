import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:people_management/screens/auth/login_screen.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:people_management/screens/users/user_detail_screen.dart';
import 'package:people_management/screens/users/user_form_screen.dart';
import 'package:people_management/utils/user_preferences.dart';

class Users {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      avatarUrl: data['avatarUrl'],
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      await UserPreferences.clearUser();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to logout: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: const Text('Daftar Pengguna', style: AppStyles.buttonTextStyle),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.cardColor),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.cardColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserFormScreen(user: null),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.cardColor),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada pengguna.',
                style: AppStyles.subHeadingStyle,
              ),
            );
          }

          final users =
              snapshot.data!.docs.map((doc) {
                return Users.fromFirestore(doc);
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                    backgroundImage:
                        user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child:
                        user.avatarUrl == null
                            ? Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primaryPurple.withOpacity(0.7),
                            )
                            : null,
                  ),
                  title: Text(
                    user.name,
                    style: AppStyles.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppStyles.subHeadingStyle.copyWith(fontSize: 13),
                      ),
                      Text(
                        'Role: ${user.role}',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 12,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.hintColor,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
