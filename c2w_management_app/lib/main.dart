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
<<<<<<< HEAD
    return const MaterialApp(
      home:SplashScreen()
=======
    return 
      MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
>>>>>>> 1d767b6690d5633b7194fc90efd9cdb91242936f
    );
  }
}
