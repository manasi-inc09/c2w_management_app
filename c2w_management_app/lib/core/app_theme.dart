import 'package:flutter/material.dart';

class AppTheme {
  final Color appBarBackgroundColor = const Color(0xFF11182D);
  final Color bodyBackgroundColor = const Color(0xFF070A1B);
  final Color cardBackgroundColor = const Color(0xFF121A2E);
  final Color surfaceColor = const Color(0xFF171F36);
  final Color borderColor = const Color(0xFF2A3357);
  final Color primaryColor = const Color(0xFF7C6CFF);
  final Color accentColor = const Color(0xFF00A3FF);
  final Color textPrimary = Colors.white;
  final Color textSecondary = const Color(0xFF9AA5C3);
  final Color textMuted = const Color(0xFF6C7891);
  final Color successColor = const Color(0xFF19D18A);
  final Color dangerColor = const Color(0xFFE35E74);

  LinearGradient get premiumGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A1A55), Color(0xFF171F36), Color(0xFF070A1B)],
      );
}