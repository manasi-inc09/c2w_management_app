import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterExpenses', () {
    test('filters transactions by category, subcategory, member, and date', () {
      final selectedDate = DateTime(2026, 10, 21);
      final matchingExpense = <String, dynamic>{
        'category': 'Food',
        'subCategory': 'Breakfast',
        'email': 'member@example.com',
        'expenseDate': Timestamp.fromDate(DateTime(2026, 10, 21, 9)),
      };
      final otherExpense = <String, dynamic>{
        'category': 'Travel',
        'subCategory': 'Bus',
        'email': 'other@example.com',
        'expenseDate': Timestamp.fromDate(DateTime(2026, 10, 21, 9)),
      };

      final result = filterExpenses(
        [matchingExpense, otherExpense],
        ExpenseFilterSelection(
          category: 'Food',
          subCategory: 'Breakfast',
          memberEmail: 'member@example.com',
          date: selectedDate,
        ),
        currentEmail: 'instructor_admin@example.com',
      );

      expect(result, [matchingExpense]);
    });

    test('normalizes role-prefixed email for My Transactions', () {
      final ownExpense = <String, dynamic>{'email': 'admin@example.com'};
      final anotherExpense = <String, dynamic>{'email': 'other@example.com'};

      final result = filterExpenses(
        [ownExpense, anotherExpense],
        const ExpenseFilterSelection(transactionType: 'My Transactions'),
        currentEmail: 'instructor_admin@example.com',
      );

      expect(result, [ownExpense]);
    });

    test('Recent Transactions includes only the last seven days', () {
      final now = DateTime.now();
      final recentExpense = <String, dynamic>{
        'expenseDate': Timestamp.fromDate(
          now.subtract(const Duration(days: 6)),
        ),
      };
      final oldExpense = <String, dynamic>{
        'expenseDate': Timestamp.fromDate(
          now.subtract(const Duration(days: 8)),
        ),
      };
      final futureExpense = <String, dynamic>{
        'expenseDate': Timestamp.fromDate(now.add(const Duration(days: 1))),
      };

      final result = filterExpenses(
        [recentExpense, oldExpense, futureExpense],
        const ExpenseFilterSelection(transactionType: 'Recent Transactions'),
        currentEmail: null,
      );

      expect(result, [recentExpense]);
    });
  });
}
