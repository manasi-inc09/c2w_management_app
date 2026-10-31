import 'package:c2w_management_app/features/expense/instructor/domain/usecases/create_instructor_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';

class InstructorExpenseBloc extends CreateExpenseBloc {
  InstructorExpenseBloc({
    required CreateInstructorExpenseUseCase createExpenseUseCase,
  }) : super(
         createExpenseUseCase: _InstructorExpenseCreator(createExpenseUseCase),
       );
}

class _InstructorExpenseCreator implements ExpenseCreator, ExpenseDeleter {
  final CreateInstructorExpenseUseCase _useCase;

  _InstructorExpenseCreator(this._useCase);

  @override
  Future<String> call(Expense expense) {
    return _useCase.createExpense(expense);
  }

  @override
  Future<void> deleteExpense({
    required String expenseId,
    required String reason,
    String? groupId,
    String? contributionId,
  }) {
    return _useCase.deleteExpense(
      expenseId: expenseId,
      reason: reason,
      groupId: groupId,
      contributionId: contributionId,
    );
  }
}
