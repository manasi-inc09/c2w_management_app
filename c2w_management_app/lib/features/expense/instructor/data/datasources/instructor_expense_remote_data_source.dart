import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class InstructorExpenseRemoteDataSource {
  final ExpenseRemoteDataSource _expenseDataSource;

  InstructorExpenseRemoteDataSource({
    required ExpenseRemoteDataSource expenseDataSource,
  }) : _expenseDataSource = expenseDataSource;

  Future<String> createExpense(Expense expense) {
    return _expenseDataSource.createExpense(expense);
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
