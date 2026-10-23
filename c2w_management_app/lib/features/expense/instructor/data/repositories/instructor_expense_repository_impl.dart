import 'package:c2w_management_app/features/expense/instructor/data/datasources/instructor_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/instructor/domain/repositories/instructor_expense_repository.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class InstructorExpenseRepositoryImpl implements InstructorExpenseRepository {
  final InstructorExpenseRemoteDataSource _remoteDataSource;

  InstructorExpenseRepositoryImpl({
    required InstructorExpenseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<String> createExpense(Expense expense) {
    return _remoteDataSource.createExpense(expense);
  }
}
