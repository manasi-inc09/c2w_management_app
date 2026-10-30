import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/repositories/teamlead_expense_repositories.dart';

abstract interface class ExpenseCreator {
  Future<String> call(Expense expense);
}

abstract interface class ExpenseUpdater {
  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  });
}

class CreateExpenseUseCase implements ExpenseCreator, ExpenseUpdater {
  final ExpenseRepository repository;

  CreateExpenseUseCase(this.repository);

  @override
  Future<String> call(Expense expense) {
    return repository.createExpense(expense);
  }

  @override
  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  }) {
    return repository.updateExpense(
      expenseId: expenseId,
      expense: expense,
      existingReceiptUrl: existingReceiptUrl,
    );
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

  Stream<List<Map<String, dynamic>>> watchExpenseHistoryByEmail(String email) {
    return repository.watchExpenseHistoryByEmail(email);
  }

  Stream<List<Map<String, dynamic>>> watchAllExpenseHistory() {
    return repository.watchAllExpenseHistory();
  }

  Future<List<Map<String, dynamic>>> getAllExpenseHistory() {
    return repository.getAllExpenseHistory();
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

  Future<List<Map<String, dynamic>>> getWalletTopUpHistory() {
    return repository.getWalletTopUpHistory();
  }

  Future<WalletFinancialSummary> getWalletFinancialSummary() {
    return repository.getWalletFinancialSummary();
  }

  Future<void> settleWalletExpense({
    required String expenseId,
    String? groupId,
    String? contributionId,
    required double amount,
    required bool fromWallet,
  }) {
    return repository.settleWalletExpense(
      expenseId: expenseId,
      groupId: groupId,
      contributionId: contributionId,
      amount: amount,
      fromWallet: fromWallet,
    );
  }

  Future<List<Map<String, dynamic>>> getMembers() {
    return repository.getMembers();
  }

  Future<List<Map<String, dynamic>>> getAllMemberExpenses() {
    return repository.getAllMemberExpenses();
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
    required String company,
    required List<String> subCategories,
  }) {
    return repository.addExpenseCategory(
      name: name,
      company: company,
      subCategories: subCategories,
    );
  }

  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required String company,
    required List<String> subCategories,
  }) {
    return repository.updateExpenseCategory(
      id: id,
      name: name,
      company: company,
      subCategories: subCategories,
    );
  }
}
