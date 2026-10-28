import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

abstract class MentorExpenseRepository {
  Future<String> createExpense(Expense expense);

  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  });
}
