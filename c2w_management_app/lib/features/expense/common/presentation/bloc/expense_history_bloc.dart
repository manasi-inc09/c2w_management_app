import 'dart:async';

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
  static const _loadTimeout = Duration(seconds: 30);
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
    await _loadStream(
      _expenseUseCase.watchExpenseHistoryByEmail(event.email),
      emit,
    );
  }

  Future<void> _loadAll(
    LoadAllExpenses event,
    Emitter<ExpenseHistoryState> emit,
  ) async {
    await _loadStream(_expenseUseCase.watchAllExpenseHistory(), emit);
  }

  Future<void> _loadStream(
    Stream<List<Map<String, dynamic>>> expensesStream,
    Emitter<ExpenseHistoryState> emit,
  ) async {
    emit(ExpenseHistoryLoading());
    final iterator = StreamIterator(expensesStream);
    try {
      final hasInitialData = await iterator.moveNext().timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException(
          'Expense loading timed out after 30 seconds.',
        ),
      );
      if (!hasInitialData) {
        emit(ExpenseHistoryFailure('No response received from the server.'));
        return;
      }

      emit(ExpenseHistoryLoaded(iterator.current));
      while (await iterator.moveNext()) {
        emit(ExpenseHistoryLoaded(iterator.current));
      }
    } catch (error) {
      if (!emit.isDone) {
        emit(ExpenseHistoryFailure(_getErrorMessage(error)));
      }
    } finally {
      await iterator.cancel();
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
