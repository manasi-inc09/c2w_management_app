import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_event.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  final ExpenseCreator createExpenseUseCase;

  CreateExpenseBloc({required this.createExpenseUseCase})
    : super(CreateExpenseInitial()) {
    on<SubmitExpenseEvent>(_onSubmitExpense);
  }

  Future<void> _onSubmitExpense(
    SubmitExpenseEvent event,
    Emitter<CreateExpenseState> emit,
  ) async {
    emit(CreateExpenseLoading());

    try {
      await createExpenseUseCase(event.expense);
      emit(CreateExpenseSuccess());
    } catch (error) {
      emit(CreateExpenseFailure(_getErrorMessage(error)));
    }
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}
