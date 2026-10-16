import 'package:c2w_management_app/features/super_admin/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/expense_manager.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/manage_categories.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/members_detail_list.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/memberslist.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/transaction_details.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/view_all_expenses.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home:ExpenseManager()
    );
  }
}
