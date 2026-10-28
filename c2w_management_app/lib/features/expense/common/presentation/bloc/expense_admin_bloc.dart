import 'dart:async';

import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadExpenseManagerData {}

class ExpenseManagerInitial {}

class ExpenseManagerLoading {}

class ExpenseManagerDataLoaded {
  final List<Map<String, dynamic>> expenses;
  final int memberCount;

  ExpenseManagerDataLoaded({required this.expenses, required this.memberCount});
}

class ExpenseManagerFailure {
  final String message;

  ExpenseManagerFailure(this.message);
}

class ExpenseManagerBloc extends Bloc<LoadExpenseManagerData, Object> {
  static const _loadTimeout = Duration(seconds: 30);
  final CreateExpenseUseCase _expenseUseCase;

  ExpenseManagerBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(ExpenseManagerInitial()) {
    on<LoadExpenseManagerData>(_load);
  }

  Future<void> _load(LoadExpenseManagerData event, Emitter<Object> emit) async {
    emit(ExpenseManagerLoading());
    try {
      final results = await Future.wait([
        _expenseUseCase.getAllExpenses(),
        _expenseUseCase.getMembers(),
      ]).timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException(
          'Expense data loading timed out after 30 seconds.',
        ),
      );
      final expenses = results[0];
      final members = results[1];
      _sortExpenses(expenses);
      emit(
        ExpenseManagerDataLoaded(
          expenses: expenses,
          memberCount: members.length,
        ),
      );
    } catch (error) {
      emit(ExpenseManagerFailure(_errorMessage(error)));
    }
  }
}

class LoadMembers {}

class MembersInitial {}

class MembersLoading {}

class MembersLoaded {
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> expenses;

  MembersLoaded(this.members, this.expenses);
}

class MembersFailure {
  final String message;

  MembersFailure(this.message);
}

class MembersBloc extends Bloc<LoadMembers, Object> {
  static const _loadTimeout = Duration(seconds: 30);
  final CreateExpenseUseCase _expenseUseCase;

  MembersBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(MembersInitial()) {
    on<LoadMembers>(_load);
  }

  Future<void> _load(LoadMembers event, Emitter<Object> emit) async {
    emit(MembersLoading());
    try {
      final results = await Future.wait([
        _expenseUseCase.getMembers(),
        _expenseUseCase.getAllExpenses(),
      ]).timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException(
          'Member data loading timed out after 30 seconds.',
        ),
      );
      final members = results[0];
      final expenses = results[1];
      final expensesByEmail = <String, List<Map<String, dynamic>>>{};

      for (final expense in expenses) {
        final email = expense['email']?.toString();
        if (email != null && email.isNotEmpty) {
          expensesByEmail.putIfAbsent(email, () => []).add(expense);
        }
      }

      for (final member in members) {
        final memberExpenses =
            expensesByEmail[member['email']?.toString() ?? ''] ?? const [];
        member['totalAmount'] = memberExpenses.fold<double>(
          0,
          (runningTotal, expense) => runningTotal + _amount(expense['amount']),
        );
      }
      members.sort(
        (first, second) => (first['name'] as String).toLowerCase().compareTo(
          (second['name'] as String).toLowerCase(),
        ),
      );
      emit(MembersLoaded(members, expenses));
    } catch (error) {
      emit(MembersFailure(_errorMessage(error)));
    }
  }
}

class LoadMemberDetails {
  final Map<String, dynamic> member;

  LoadMemberDetails(this.member);
}

class MemberDetailsInitial {}

class MemberDetailsLoading {}

class MemberDetailsLoaded {
  final Map<String, dynamic> member;
  final List<Map<String, dynamic>> expenses;

  MemberDetailsLoaded({required this.member, required this.expenses});
}

class MemberDetailsFailure {
  final String message;

  MemberDetailsFailure(this.message);
}

class MemberDetailsBloc extends Bloc<LoadMemberDetails, Object> {
  static const _loadTimeout = Duration(seconds: 30);
  final CreateExpenseUseCase _expenseUseCase;

  MemberDetailsBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(MemberDetailsInitial()) {
    on<LoadMemberDetails>(_load);
  }

  Future<void> _load(LoadMemberDetails event, Emitter<Object> emit) async {
    emit(MemberDetailsLoading());
    try {
      final email = event.member['email']?.toString();
      if (email == null || email.isEmpty) {
        throw Exception('The selected member does not have an email address.');
      }
      final expenses = await _expenseUseCase
          .getExpensesByEmail(email)
          .timeout(
            _loadTimeout,
            onTimeout: () => throw TimeoutException(
              'Member expense loading timed out after 30 seconds.',
            ),
          );
      _sortExpenses(expenses);
      emit(MemberDetailsLoaded(member: event.member, expenses: expenses));
    } catch (error) {
      emit(MemberDetailsFailure(_errorMessage(error)));
    }
  }
}

void _sortExpenses(List<Map<String, dynamic>> expenses) {
  expenses.sort(
    (first, second) => (_expenseDate(second)?.millisecondsSinceEpoch ?? 0)
        .compareTo(_expenseDate(first)?.millisecondsSinceEpoch ?? 0),
  );
}

DateTime? _expenseDate(Map<String, dynamic> expense) {
  final value = expense['expenseDate'];
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  final submittedAt = expense['submittedAt'];
  if (submittedAt is Timestamp) return submittedAt.toDate();
  return null;
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _errorMessage(Object error) {
  final message = error.toString();
  if (message.startsWith('Exception: ')) {
    return message.substring('Exception: '.length);
  }
  return message;
}
