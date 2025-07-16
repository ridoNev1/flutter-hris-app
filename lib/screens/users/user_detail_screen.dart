// lib/screens/users/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:people_management/screens/users/user_form_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final Users user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text(user.name, style: AppStyles.buttonTextStyle),
        backgroundColor: AppColors.primaryPurple,
        iconTheme: const IconThemeData(color: AppColors.cardColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.cardColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserFormScreen(user: user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.cardColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Delete user functionality not implemented yet!',
                  ),
                ),
              );
            },
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
                        user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child:
                        user.avatarUrl == null
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
                  user.name,
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
                  user.email,
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
                  user.role,
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
