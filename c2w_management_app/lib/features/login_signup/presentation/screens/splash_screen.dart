import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
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