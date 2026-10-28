import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

String _walletUserEmail() =>
    FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail ?? '';

bool canTopUpWallet() => _walletUserEmail().startsWith('superadmin_');

bool canSettleWalletExpenses() {
  final email = _walletUserEmail();
  return email.startsWith('superadmin_') || email.startsWith('instructor_');
}

enum WalletActionKind { topUp, settlement }

abstract class WalletEvent {}

class LoadWallet extends WalletEvent {}

class AddWalletTopUp extends WalletEvent {
  final double amount;

  AddWalletTopUp(this.amount);
}

class SettleWalletExpense extends WalletEvent {
  final String expenseId;
  final double amount;
  final bool fromWallet;

  SettleWalletExpense({
    required this.expenseId,
    required this.amount,
    required this.fromWallet,
  });
}

class _WalletDataChanged extends WalletEvent {
  final double? balance;
  final List<Map<String, dynamic>>? expenses;

  _WalletDataChanged({this.balance, this.expenses});
}

class _WalletStreamFailure extends WalletEvent {
  final Object error;

  _WalletStreamFailure(this.error);
}

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoadFailure extends WalletState {
  final String message;

  WalletLoadFailure(this.message);
}

class WalletLoaded extends WalletState {
  final double balance;
  final List<Map<String, dynamic>> expenses;

  WalletLoaded({required this.balance, required this.expenses});
}

class WalletActionInProgress extends WalletLoaded {
  WalletActionInProgress({required super.balance, required super.expenses});
}

class WalletActionSuccess extends WalletLoaded {
  final WalletActionKind action;

  WalletActionSuccess({
    required super.balance,
    required super.expenses,
    required this.action,
  });
}

class WalletActionFailure extends WalletLoaded {
  final String message;
  final WalletActionKind action;

  WalletActionFailure({
    required super.balance,
    required super.expenses,
    required this.message,
    required this.action,
  });
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  static const _loadTimeout = Duration(seconds: 30);
  final CreateExpenseUseCase _expenseUseCase;
  StreamSubscription<double>? _balanceSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _expensesSubscription;
  Timer? _initialLoadTimer;
  double? _latestBalance;
  List<Map<String, dynamic>>? _latestExpenses;

  WalletBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(WalletInitial()) {
    on<LoadWallet>(_load);
    on<AddWalletTopUp>(_topUp);
    on<SettleWalletExpense>(_settle);
    on<_WalletDataChanged>(_updateWalletData);
    on<_WalletStreamFailure>((event, emit) {
      _initialLoadTimer?.cancel();
      emit(WalletLoadFailure(_errorMessage(event.error)));
    });
  }

  Future<List<Map<String, dynamic>>> getWalletTopUpHistory() {
    if (!canTopUpWallet()) {
      throw Exception('Only SuperAdmin can view wallet top-up history.');
    }
    return _expenseUseCase.getWalletTopUpHistory();
  }

  Future<WalletFinancialSummary> getWalletFinancialSummary() {
    if (!canTopUpWallet()) {
      throw Exception('Only SuperAdmin can view wallet financial summary.');
    }
    return _expenseUseCase.getWalletFinancialSummary();
  }

  Future<void> _load(LoadWallet event, Emitter<WalletState> emit) async {
    await _balanceSubscription?.cancel();
    await _expensesSubscription?.cancel();
    _initialLoadTimer?.cancel();
    _latestBalance = null;
    _latestExpenses = null;
    emit(WalletLoading());
    _initialLoadTimer = Timer(_loadTimeout, () {
      if (!isClosed && (_latestBalance == null || _latestExpenses == null)) {
        add(
          _WalletStreamFailure(
            TimeoutException('Wallet loading timed out after 30 seconds.'),
          ),
        );
      }
    });
    _balanceSubscription = _expenseUseCase.watchWalletBalance().listen(
      (balance) {
        if (!isClosed) add(_WalletDataChanged(balance: balance));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!isClosed) add(_WalletStreamFailure(error));
      },
    );
    _expensesSubscription = _expenseUseCase.watchAllExpenses().listen(
      (expenses) {
        if (!isClosed) add(_WalletDataChanged(expenses: expenses));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!isClosed) add(_WalletStreamFailure(error));
      },
    );
  }

  void _updateWalletData(_WalletDataChanged event, Emitter<WalletState> emit) {
    if (event.balance != null) _latestBalance = event.balance;
    if (event.expenses != null) _latestExpenses = event.expenses;
    if (_latestBalance == null || _latestExpenses == null) return;
    _initialLoadTimer?.cancel();

    if (state is! WalletActionInProgress) {
      emit(WalletLoaded(balance: _latestBalance!, expenses: _latestExpenses!));
    }
  }

  Future<void> _topUp(AddWalletTopUp event, Emitter<WalletState> emit) async {
    final current = _currentData();
    if (!canTopUpWallet()) {
      emit(
        WalletActionFailure(
          balance: current.balance,
          expenses: current.expenses,
          message: 'Only SuperAdmin can top up the wallet.',
          action: WalletActionKind.topUp,
        ),
      );
      return;
    }

    emit(
      WalletActionInProgress(
        balance: current.balance,
        expenses: current.expenses,
      ),
    );
    try {
      await _expenseUseCase.addWalletTopUp(event.amount);
      final updated = await _readWallet();
      _latestBalance = updated.balance;
      _latestExpenses = updated.expenses;
      emit(
        WalletActionSuccess(
          balance: updated.balance,
          expenses: updated.expenses,
          action: WalletActionKind.topUp,
        ),
      );
    } catch (error) {
      emit(
        WalletActionFailure(
          balance: current.balance,
          expenses: current.expenses,
          message: _errorMessage(error),
          action: WalletActionKind.topUp,
        ),
      );
    }
  }

  Future<void> _settle(
    SettleWalletExpense event,
    Emitter<WalletState> emit,
  ) async {
    final current = _currentData();
    if (!canSettleWalletExpenses()) {
      emit(
        WalletActionFailure(
          balance: current.balance,
          expenses: current.expenses,
          message: 'Only SuperAdmin or Instructor can settle transactions.',
          action: WalletActionKind.settlement,
        ),
      );
      return;
    }

    emit(
      WalletActionInProgress(
        balance: current.balance,
        expenses: current.expenses,
      ),
    );
    try {
      await _expenseUseCase.settleWalletExpense(
        expenseId: event.expenseId,
        amount: event.amount,
        fromWallet: event.fromWallet,
      );
      final updated = await _readWallet();
      _latestBalance = updated.balance;
      _latestExpenses = updated.expenses;
      emit(
        WalletActionSuccess(
          balance: updated.balance,
          expenses: updated.expenses,
          action: WalletActionKind.settlement,
        ),
      );
    } catch (error) {
      emit(
        WalletActionFailure(
          balance: current.balance,
          expenses: current.expenses,
          message: _errorMessage(error),
          action: WalletActionKind.settlement,
        ),
      );
    }
  }

  Future<WalletLoaded> _readWallet() async {
    final balance = await _expenseUseCase.getWalletBalance();
    final expenses = await _expenseUseCase.getAllExpenses();
    return WalletLoaded(balance: balance, expenses: expenses);
  }

  WalletLoaded _currentData() {
    final current = state;
    if (current is WalletLoaded) return current;
    return WalletLoaded(balance: 0, expenses: const []);
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  Future<void> close() async {
    _initialLoadTimer?.cancel();
    await _balanceSubscription?.cancel();
    await _expensesSubscription?.cancel();
    return super.close();
  }
}
