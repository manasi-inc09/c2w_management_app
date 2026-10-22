import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/repositories/teamlead_expense_repositories.dart';

abstract interface class ExpenseCreator {
  Future<String> call(Expense expense);
}

class CreateExpenseUseCase implements ExpenseCreator {
  final ExpenseRepository repository;

  CreateExpenseUseCase(this.repository);

  @override
  Future<String> call(Expense expense) {
    return repository.createExpense(expense);
  }

  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email) {
    return repository.watchExpensesByEmail(email);
  }

  Stream<List<Map<String, dynamic>>> watchAllExpenses() {
    return repository.watchAllExpenses();
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() {
    return repository.getAllExpenses();
  }

  Future<List<Map<String, dynamic>>> getMembers() {
    return repository.getMembers();
  }

  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email) {
    return repository.getExpensesByEmail(email);
  }
}
