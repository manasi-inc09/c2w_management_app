import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ExpenseHistoryEvent {}

class LoadExpensesByEmail extends ExpenseHistoryEvent {
  final String email;

  LoadExpensesByEmail(this.email);
}

class LoadAllExpenses extends ExpenseHistoryEvent {}

abstract class ExpenseHistoryState {}

class ExpenseHistoryInitial extends ExpenseHistoryState {}

class ExpenseHistoryLoading extends ExpenseHistoryState {}

class ExpenseHistoryLoaded extends ExpenseHistoryState {
  final List<Map<String, dynamic>> expenses;

  ExpenseHistoryLoaded(this.expenses);
}

class ExpenseHistoryFailure extends ExpenseHistoryState {
  final String message;

  ExpenseHistoryFailure(this.message);
}

class ExpenseHistoryBloc
    extends Bloc<ExpenseHistoryEvent, ExpenseHistoryState> {
  final CreateExpenseUseCase _expenseUseCase;

  ExpenseHistoryBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(ExpenseHistoryInitial()) {
    on<LoadExpensesByEmail>(_loadByEmail);
    on<LoadAllExpenses>(_loadAll);
  }

  Future<void> _loadByEmail(
    LoadExpensesByEmail event,
    Emitter<ExpenseHistoryState> emit,
  ) async {
    emit(ExpenseHistoryLoading());
    await emit.forEach(
      _expenseUseCase.watchExpensesByEmail(event.email),
      onData: ExpenseHistoryLoaded.new,
      onError: (error, stackTrace) =>
          ExpenseHistoryFailure(_getErrorMessage(error)),
    );
  }

  Future<void> _loadAll(
    LoadAllExpenses event,
    Emitter<ExpenseHistoryState> emit,
  ) async {
    emit(ExpenseHistoryLoading());
    await emit.forEach(
      _expenseUseCase.watchAllExpenses(),
      onData: ExpenseHistoryLoaded.new,
      onError: (error, stackTrace) =>
          ExpenseHistoryFailure(_getErrorMessage(error)),
    );
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}
