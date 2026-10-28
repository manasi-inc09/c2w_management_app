import 'package:c2w_management_app/features/expense/mentor/data/datasources/mentor_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/mentor/domain/repositories/mentor_expense_repository.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class MentorExpenseRepositoryImpl implements MentorExpenseRepository {
  final MentorExpenseRemoteDataSource _remoteDataSource;

  MentorExpenseRepositoryImpl({
    required MentorExpenseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<String> createExpense(Expense expense) {
    return _remoteDataSource.createExpense(expense);
  }

  @override
  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  }) {
    return _remoteDataSource.updateExpense(
      expenseId: expenseId,
      expense: expense,
      existingReceiptUrl: existingReceiptUrl,
    );
  }
}
