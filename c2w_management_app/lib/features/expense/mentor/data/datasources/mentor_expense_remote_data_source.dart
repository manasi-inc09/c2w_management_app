import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class MentorExpenseRemoteDataSource {
  final ExpenseRemoteDataSource _expenseDataSource;

  MentorExpenseRemoteDataSource({
    required ExpenseRemoteDataSource expenseDataSource,
  }) : _expenseDataSource = expenseDataSource;

  Future<String> createExpense(Expense expense) {
    return _expenseDataSource.createExpense(expense);
  }

  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  }) {
    return _expenseDataSource.updateExpense(
      expenseId: expenseId,
      expense: expense,
      existingReceiptUrl: existingReceiptUrl,
    );
  }

  Future<void> deleteExpense({
    required String expenseId,
    required String reason,
    String? groupId,
    String? contributionId,
  }) {
    return _expenseDataSource.deleteExpense(
      expenseId: expenseId,
      reason: reason,
      groupId: groupId,
      contributionId: contributionId,
    );
  }
}
