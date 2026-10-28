import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';

enum _ExpenseMenuAction { newTransaction, newCategory, myTransactions }

class FloatingButton {
  static Widget getFloatingButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final size = renderBox.size;
            final position = renderBox.localToGlobal(Offset.zero);
            final email = (AuthRepository.authEmail ?? '').toLowerCase();
            final canViewMyTransactions =
                email.contains('instructor') || email.contains('superadmin');

            final action = await showMenu<_ExpenseMenuAction>(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx,
                position.dy - 120,
                position.dx + size.width,
                position.dy,
              ),
              color: AppTheme().appBarBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              items: [
                const PopupMenuItem(
                  value: _ExpenseMenuAction.newTransaction,
                  child: SizedBox(
                    width: 170,
                    child: Text(
                      'New Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (canManageExpenseCategories())
                  const PopupMenuItem(
                    value: _ExpenseMenuAction.newCategory,
                    child: SizedBox(
                      width: 170,
                      child: Text(
                        'New Categories',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                if (canViewMyTransactions)
                  const PopupMenuItem(
                    value: _ExpenseMenuAction.myTransactions,
                    child: SizedBox(
                      width: 170,
                      child: Text(
                        'My Transactions',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            );

            if (!context.mounted || action == null) return;

            final route = switch (action) {
              _ExpenseMenuAction.newTransaction => MaterialPageRoute(
                builder: (_) => CreateNewTransaction(),
              ),
              _ExpenseMenuAction.newCategory => MaterialPageRoute(
                builder: (_) => const AddNewCategory(),
              ),
              _ExpenseMenuAction.myTransactions => MaterialPageRoute(
                builder: (_) =>
                    const IndividualExpenses(showOnlyMyTransactions: true),
              ),
            };

            await Navigator.push(context, route);
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }
}
