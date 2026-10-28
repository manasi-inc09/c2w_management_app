import 'package:c2w_management_app/features/expense/mentor/domain/repositories/mentor_expense_repository.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class CreateMentorExpenseUseCase {
  final MentorExpenseRepository _repository;

  CreateMentorExpenseUseCase(this._repository);

  Future<String> createExpense(Expense expense) {
    return _repository.createExpense(expense);
  }

  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  }) {
    return _repository.updateExpense(
      expenseId: expenseId,
      expense: expense,
      existingReceiptUrl: existingReceiptUrl,
    );
  }
}
