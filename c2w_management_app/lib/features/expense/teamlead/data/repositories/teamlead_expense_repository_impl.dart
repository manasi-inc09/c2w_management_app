import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_expense_remote_data_source.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';
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

  @override
  Future<void> deleteExpense({
    required String expenseId,
    required String reason,
    String? groupId,
    String? contributionId,
  }) {
    return _remoteDataSource.deleteExpense(
      expenseId: expenseId,
      reason: reason,
      groupId: groupId,
      contributionId: contributionId,
    );
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
  Stream<List<Map<String, dynamic>>> watchExpenseHistoryByEmail(String email) {
    return _remoteDataSource.watchExpenseHistoryByEmail(email);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAllExpenseHistory() {
    return _remoteDataSource.watchAllExpenseHistory();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllExpenseHistory() {
    return _remoteDataSource.getAllExpenseHistory();
  }

  @override
  Future<double> getWalletBalance() {
    return _remoteDataSource.getWalletBalance();
  }

  @override
  Stream<double> watchWalletBalance() {
    return _remoteDataSource.watchWalletBalance();
  }

  @override
  Future<void> addWalletTopUp(double amount) {
    return _remoteDataSource.addWalletTopUp(amount);
  }

  @override
  Future<List<Map<String, dynamic>>> getWalletTopUpHistory() {
    return _remoteDataSource.getWalletTopUpHistory();
  }

  @override
  Future<WalletFinancialSummary> getWalletFinancialSummary() {
    return _remoteDataSource.getWalletFinancialSummary();
  }

  @override
  Future<void> settleWalletExpense({
    required String expenseId,
    String? groupId,
    String? contributionId,
    required double amount,
    required bool fromWallet,
  }) {
    return _remoteDataSource.settleWalletExpense(
      expenseId: expenseId,
      groupId: groupId,
      contributionId: contributionId,
      amount: amount,
      fromWallet: fromWallet,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMembers() {
    return _remoteDataSource.getMembers();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMemberExpenses() {
    return _remoteDataSource.getAllMemberExpenses();
  }

  @override
  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email) {
    return _remoteDataSource.getExpensesByEmail(email);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchExpenseCategories() {
    return _remoteDataSource.watchExpenseCategories();
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenseCategories() {
    return _remoteDataSource.getExpenseCategories();
  }

  @override
  Future<void> addExpenseCategory({
    required String name,
    required String company,
    required List<String> subCategories,
  }) {
    return _remoteDataSource.addExpenseCategory(
      name: name,
      company: company,
      subCategories: subCategories,
    );
  }

  @override
  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required String company,
    required List<String> subCategories,
  }) {
    return _remoteDataSource.updateExpenseCategory(
      id: id,
      name: name,
      company: company,
      subCategories: subCategories,
    );
  }
}
