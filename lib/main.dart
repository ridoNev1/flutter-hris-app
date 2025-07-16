import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:people_management/firebase_options.dart';
import 'package:people_management/screens/auth/login_screen.dart';
import 'package:people_management/screens/users/user_list_screen.dart';
import 'package:people_management/utils/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? firebaseUser = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? localUserData = await UserPreferences.getUser();

  Widget initialScreen;
  if (firebaseUser != null) {
    initialScreen = UserListScreen();
    if (localUserData == null || localUserData['uid'] != firebaseUser.uid) {
      await UserPreferences.saveUser(firebaseUser);
    }
  } else if (localUserData != null && localUserData['uid'] != null) {
    initialScreen = UserListScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialScreen,
    );
  }
}
