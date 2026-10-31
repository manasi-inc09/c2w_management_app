import 'package:c2w_management_app/features/expense/instructor/domain/repositories/instructor_expense_repository.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

class CreateInstructorExpenseUseCase {
  final InstructorExpenseRepository _repository;

  CreateInstructorExpenseUseCase(this._repository);

  Future<String> createExpense(Expense expense) {
    return _repository.createExpense(expense);
  }

  Future<void> deleteExpense({
    required String expenseId,
    required String reason,
    String? groupId,
    String? contributionId,
  }) {
    return _repository.deleteExpense(
      expenseId: expenseId,
      reason: reason,
      groupId: groupId,
      contributionId: contributionId,
    );
  }
}
