import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_event.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  final ExpenseCreator createExpenseUseCase;

  CreateExpenseBloc({required this.createExpenseUseCase})
    : super(CreateExpenseInitial()) {
    on<SubmitExpenseEvent>(_onSubmitExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
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

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<CreateExpenseState> emit,
  ) async {
    emit(CreateExpenseLoading());

    try {
      final updater = createExpenseUseCase;
      if (updater is! ExpenseUpdater) {
        throw Exception(
          'Transaction editing is not available for this account.',
        );
      }
      await (updater as ExpenseUpdater).updateExpense(
        expenseId: event.expenseId,
        expense: event.expense,
        existingReceiptUrl: event.existingReceiptUrl,
      );
      emit(CreateExpenseSuccess());
    } catch (error) {
      emit(CreateExpenseFailure(_getErrorMessage(error)));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<CreateExpenseState> emit,
  ) async {
    emit(CreateExpenseLoading());

    try {
      final deleter = createExpenseUseCase;
      if (deleter is! ExpenseDeleter) {
        throw Exception(
          'Transaction deletion is not available for this account.',
        );
      }
      await (deleter as ExpenseDeleter).deleteExpense(
        expenseId: event.expenseId,
        reason: event.reason,
        groupId: event.groupId,
        contributionId: event.contributionId,
      );
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
