import 'package:c2w_management_app/features/expense/mentor/domain/usecases/create_mentor_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';

class MentorExpenseBloc extends CreateExpenseBloc {
  MentorExpenseBloc({required CreateMentorExpenseUseCase createExpenseUseCase})
    : super(createExpenseUseCase: _MentorExpenseCreator(createExpenseUseCase));
}

class _MentorExpenseCreator implements ExpenseCreator {
  final CreateMentorExpenseUseCase _useCase;

  _MentorExpenseCreator(this._useCase);

  @override
  Future<String> call(Expense expense) {
    return _useCase.createExpense(expense);
  }
}
