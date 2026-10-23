import 'package:c2w_management_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettleButton {
  Widget getSettleButton(
    BuildContext context,
    String text, {
    Widget? container,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppTheme().appBarBackgroundColor,
      child: Column(
        children: [
          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    if (onTap != null) {
                      onTap();
                    } else if (container != null) {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => container,
                        isScrollControlled: true,
                        backgroundColor: AppTheme().appBarBackgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                      );
                    }
                  },
            child: Container(
              margin: const EdgeInsets.all(20),
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        text,
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
