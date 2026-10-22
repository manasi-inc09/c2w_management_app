import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/individual_expenses.dart';
import 'package:flutter/material.dart';

class FloatingButton {
  static Widget getFloatingButton(){
    return Builder(
  builder: (context) {
    return FloatingActionButton(
      onPressed: () {
        // Get the render box of the button to calculate its position
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero);

        // Define where the menu should pop up (near the FAB)
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx, // Left
            position.dy - 120, // Top (adjust this value to position it higher or lower relative to the FAB)
            position.dx + size.width, // Right
            position.dy, // Bottom
          ),
          color: AppTheme().appBarBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          items: [
            PopupMenuItem(
              enabled: false, // Prevents selection highlighting
              child: SizedBox(
                width: 150, // Customize width of your container popup
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>CreateNewTransaction()));
                      },
                      child: const Text(
                        'New Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNewCategory()));
                      },
                      child: const Text(
                        'New Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>IndividualExpenses()));
                      },
                      child: const Text(
                        'My Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                  ],
                ),
              ),
            ),
          ],
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  },
);
  }
}