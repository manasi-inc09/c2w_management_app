import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

abstract class ExpenseRepository {
  Future<String> createExpense(Expense expense);

  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email);

  Stream<List<Map<String, dynamic>>> watchAllExpenses();

  Future<List<Map<String, dynamic>>> getAllExpenses();

  Future<List<Map<String, dynamic>>> getMembers();

  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email);
}
