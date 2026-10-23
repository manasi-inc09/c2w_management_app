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

  Future<double> getWalletBalance() {
    return repository.getWalletBalance();
  }

  Stream<double> watchWalletBalance() {
    return repository.watchWalletBalance();
  }

  Future<void> addWalletTopUp(double amount) {
    return repository.addWalletTopUp(amount);
  }

  Future<void> settleWalletExpense({
    required String expenseId,
    required double amount,
    required bool fromWallet,
  }) {
    return repository.settleWalletExpense(
      expenseId: expenseId,
      amount: amount,
      fromWallet: fromWallet,
    );
  }

  Future<List<Map<String, dynamic>>> getMembers() {
    return repository.getMembers();
  }

  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email) {
    return repository.getExpensesByEmail(email);
  }

  Stream<List<Map<String, dynamic>>> watchExpenseCategories() {
    return repository.watchExpenseCategories();
  }

  Future<List<Map<String, dynamic>>> getExpenseCategories() {
    return repository.getExpenseCategories();
  }

  Future<void> addExpenseCategory({
    required String name,
    required List<String> subCategories,
  }) {
    return repository.addExpenseCategory(
      name: name,
      subCategories: subCategories,
    );
  }

  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required List<String> subCategories,
  }) {
    return repository.updateExpenseCategory(
      id: id,
      name: name,
      subCategories: subCategories,
    );
  }
}
