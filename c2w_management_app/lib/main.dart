import 'package:c2w_management_app/features/login_signup/presentation/screens/splash_screen.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/expense_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
      MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}
