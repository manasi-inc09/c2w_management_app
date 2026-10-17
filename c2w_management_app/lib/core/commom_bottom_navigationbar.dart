import 'package:c2w_management_app/core/app_theme.dart';
import 'package:flutter/material.dart';

class CommonBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme().appBarBackgroundColor,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_support_outlined),
          label: 'Enquiry',
          
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_rupee),
          label: 'Expense',
        ),
        
      ],
    );
  }
}