import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class UserPreferences {
  static const String _userKey = 'user_data';

  static Future<void> saveUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      Map<String, dynamic> userData = {'uid': user.uid, 'email': user.email};
      await prefs.setString(_userKey, json.encode(userData));
    } else {
      await prefs.remove(_userKey);
    }
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString(_userKey);
    if (userDataString != null && userDataString.isNotEmpty) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
