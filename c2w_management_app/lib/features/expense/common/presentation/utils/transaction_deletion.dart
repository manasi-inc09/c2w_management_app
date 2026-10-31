import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_event.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_state.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool canDeleteExpenseTransaction(Map<String, dynamic> expense) {
  if (expense['eventExpenseGroup'] == true &&
      expense['eventExpenseGroupContribution'] != true) {
    return false;
  }

  final authEmail =
      (FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail)
          ?.trim()
          .toLowerCase() ??
      '';
  final role = _roleForEmail(authEmail);
  if (role == 'instructor' || role == 'superadmin') return true;
  if (role != 'teamlead' && role != 'mentor') return false;
  if (_isSettled(expense) && !_isPrepaid(expense)) return false;

  return AuthRepository.cleanEmail(
        expense['email']?.toString(),
      ).toLowerCase() ==
      AuthRepository.cleanEmail(authEmail).toLowerCase();
}

Future<bool> deleteExpenseTransactionWithReason(
  BuildContext context,
  Map<String, dynamic> expense,
) async {
  if (!canDeleteExpenseTransaction(expense)) return false;

  final reason = await showDialog<String>(
    context: context,
    builder: (_) => const _DeleteTransactionReasonDialog(),
  );
  if (reason == null || !context.mounted) return false;

  final expenseId = expense['id']?.toString() ?? '';
  if (expenseId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This transaction could not be identified.'),
      ),
    );
    return false;
  }

  final bloc = context.read<CreateExpenseBloc>();
  await reloadAfterEvent(
    states: bloc.stream,
    dispatch: () => bloc.add(
      DeleteExpenseEvent(
        expenseId: expenseId,
        reason: reason,
        groupId: expense['eventExpenseGroupContribution'] == true
            ? expense['groupId']?.toString()
            : null,
        contributionId: expense['eventExpenseGroupContribution'] == true
            ? expense['contributionId']?.toString()
            : null,
      ),
    ),
    isComplete: (state) =>
        state is CreateExpenseSuccess || state is CreateExpenseFailure,
  );
  if (!context.mounted) return false;

  final state = bloc.state;
  final succeeded = state is CreateExpenseSuccess;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        state is CreateExpenseFailure
            ? 'Could not delete transaction: ${state.message}'
            : 'Transaction deleted and logged.',
      ),
    ),
  );
  return succeeded;
}

class _DeleteTransactionReasonDialog extends StatefulWidget {
  const _DeleteTransactionReasonDialog();

  @override
  State<_DeleteTransactionReasonDialog> createState() =>
      _DeleteTransactionReasonDialogState();
}

class _DeleteTransactionReasonDialogState
    extends State<_DeleteTransactionReasonDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2638),
      scrollable: true,
      title: const Text(
        'Delete transaction?',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This transaction will be removed and its details will be saved in the deletion log. Please provide a reason.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              maxLength: 500,
              cursorColor: Colors.blue,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Reason for deletion',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'A deletion reason is required.'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _reasonController.text.trim());
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

String? _roleForEmail(String email) {
  for (final role in ['teamlead', 'mentor', 'instructor', 'superadmin']) {
    if (email.startsWith('${role}_')) return role;
  }
  return null;
}

bool _isSettled(Map<String, dynamic> transaction) {
  final isGroupContribution =
      transaction['eventExpenseGroupContribution'] == true;
  final amount = _readAmount(
    transaction[isGroupContribution ? 'amountPaise' : 'amount'],
  );
  if (amount <= 0) return false;

  final settledAmount = _readAmount(
    transaction[isGroupContribution ? 'settledAmountPaise' : 'settledAmount'],
  );
  return settledAmount >= amount ||
      transaction['status']?.toString().trim().toLowerCase() == 'settled';
}

bool _isPrepaid(Map<String, dynamic> transaction) =>
    transaction['source']?.toString().trim().toLowerCase() == 'prepaid' ||
    transaction['paymentSource']?.toString().trim().toLowerCase() == 'prepaid';

double _readAmount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
