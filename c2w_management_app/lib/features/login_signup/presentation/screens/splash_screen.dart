import 'dart:developer';

import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/dashboard_view.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/complete_profile_screen.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    splashTimer();
  }

  Future<void> splashTimer() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    var shouldOpenDashboard = false;
    final authRepository = AuthRepository();
    try {
      final savedLoginStatus = await authRepository.isLoggedIn();
      final firebaseUser = FirebaseAuth.instance.currentUser;
      shouldOpenDashboard = savedLoginStatus && firebaseUser != null;

      if (shouldOpenDashboard) {
        AuthRepository.authEmail = firebaseUser.email;
        shouldOpenDashboard = await AuthRepository.isProfileComplete();
      } else if (savedLoginStatus) {
        await authRepository.clearLoginStatus();
      }
    } catch (error, stackTrace) {
      log('Could not check saved login status: $error', stackTrace: stackTrace);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => shouldOpenDashboard
            ? const DashboardView()
            : (AuthRepository.authEmail != null
                ? const CompleteProfileScreen()
                : const LoginScreen()),
      ),
    );
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF070A1B),
    body: SafeArea(
      child: Column(
        children: [
         
          Expanded(
            child: Center(
              child: Image.asset(
                "assets/images/sales_admin/logo.png",
                height: 200,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            "Made with ❤️ by",
            style: GoogleFonts.figtree(fontSize: 12, color: Colors.grey),
          ),
          Text(
            "INCUBATORS SYSTEMS",
            style: GoogleFonts.figtree(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 15),
        ],
      ),
    ),
  );
}
}
