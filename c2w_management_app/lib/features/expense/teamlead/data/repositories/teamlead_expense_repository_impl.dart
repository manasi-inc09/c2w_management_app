import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/repositories/teamlead_expense_repositories.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl({required ExpenseRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<String> createExpense(Expense expense) async {
    return await _remoteDataSource.createExpense(expense);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email) {
    return _remoteDataSource.watchExpensesByEmail(email);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAllExpenses() {
    return _remoteDataSource.watchAllExpenses();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllExpenses() {
    return _remoteDataSource.getAllExpenses();
  }

  @override
  Future<List<Map<String, dynamic>>> getMembers() {
    return _remoteDataSource.getMembers();
  }

  @override
  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email) {
    return _remoteDataSource.getExpensesByEmail(email);
  }
}
