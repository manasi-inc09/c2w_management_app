import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';

abstract class ExpenseRepository {
  Future<String> createExpense(Expense expense);

  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  });

  Future<void> deleteExpense({
    required String expenseId,
    required String reason,
    String? groupId,
    String? contributionId,
  });

  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email);

  Stream<List<Map<String, dynamic>>> watchAllExpenses();

  Future<List<Map<String, dynamic>>> getAllExpenses();

  Stream<List<Map<String, dynamic>>> watchExpenseHistoryByEmail(String email);

  Stream<List<Map<String, dynamic>>> watchAllExpenseHistory();

  Future<List<Map<String, dynamic>>> getAllExpenseHistory();

  Future<double> getWalletBalance();

  Stream<double> watchWalletBalance();

  Future<void> addWalletTopUp(double amount);

  Future<List<Map<String, dynamic>>> getWalletTopUpHistory();

  Future<WalletFinancialSummary> getWalletFinancialSummary();

  Future<void> settleWalletExpense({
    required String expenseId,
    String? groupId,
    String? contributionId,
    required double amount,
    required bool fromWallet,
  });

  Future<List<Map<String, dynamic>>> getMembers();

  Future<List<Map<String, dynamic>>> getAllMemberExpenses();

  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email);

  Stream<List<Map<String, dynamic>>> watchExpenseCategories();

  Future<List<Map<String, dynamic>>> getExpenseCategories();

  Future<void> addExpenseCategory({
    required String name,
    required String company,
    required List<String> subCategories,
  });

  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required String company,
    required List<String> subCategories,
  });
}
