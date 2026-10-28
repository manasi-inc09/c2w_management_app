import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomsheetSettle {
  Widget getBottomSheetOpen(Map<String, dynamic> expense) {
    return _SettleExpenseSheet(expense: expense);
  }
}

class _SettleExpenseSheet extends StatefulWidget {
  final Map<String, dynamic> expense;

  const _SettleExpenseSheet({required this.expense});

  @override
  State<_SettleExpenseSheet> createState() => _SettleExpenseSheetState();
}

class _SettleExpenseSheetState extends State<_SettleExpenseSheet> {
  final _amountController = TextEditingController();
  bool _customAmount = false;
  bool _fromWallet = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final walletBloc = context.read<WalletBloc>();
    if (walletBloc.state is WalletInitial ||
        walletBloc.state is WalletLoadFailure) {
      walletBloc.add(LoadWallet());
    }
  }

  double get _totalAmount {
    final value = widget.expense['amount'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _settle() {
    if (!canSettleWalletExpenses()) {
      _showError('Only SuperAdmin or Instructor can settle transactions.');
      return;
    }
    final amount = _customAmount
        ? double.tryParse(_amountController.text.trim())
        : _totalAmount;
    if (amount == null || amount <= 0) {
      _showError('Enter a settlement amount greater than zero.');
      return;
    }
    if (amount > _totalAmount) {
      _showError('Settlement amount cannot exceed the transaction total.');
      return;
    }
    final expenseId = widget.expense['id']?.toString();
    if (expenseId == null || expenseId.isEmpty) {
      _showError('This transaction could not be identified.');
      return;
    }

    context.read<WalletBloc>().add(
      SettleWalletExpense(
        expenseId: expenseId,
        amount: amount,
        fromWallet: _fromWallet,
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletActionSuccess) {
          Navigator.pop(context, true);
        } else if (state is WalletLoadFailure) {
          setState(() => _errorMessage = state.message);
        } else if (state is WalletActionFailure &&
            state.action == WalletActionKind.settlement) {
          setState(() => _errorMessage = state.message);
        }
      },
      builder: (context, state) {
        final balance = state is WalletLoaded ? state.balance : null;
        final isSaving = state is WalletActionInProgress;
        return SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 12,
            ),
            decoration: BoxDecoration(
              color: AppTheme().appBarBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20, top: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _modeButton(
                        title: 'Total',
                        selected: !_customAmount,
                        onTap: () => setState(() {
                          _customAmount = false;
                          _errorMessage = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _modeButton(
                        title: 'Custom',
                        selected: _customAmount,
                        onTap: () => setState(() {
                          _customAmount = true;
                          _errorMessage = null;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (_customAmount)
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Settlement amount',
                      prefixText: '₹ ',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatAmount(_totalAmount),
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(90, 36, 118, 1),
                        Color.fromRGBO(59, 46, 116, 1),
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      value: _fromWallet,
                      onChanged: (value) =>
                          setState(() => _fromWallet = value ?? false),
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      title: Text(
                        'Settle from Wallet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        balance == null
                            ? state is WalletLoadFailure
                                  ? 'Available Balance: Unavailable'
                                  : 'Available Balance: Loading…'
                            : 'Available Balance: ${_formatAmount(balance)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SettleButton().getSettleButton(
                  context,
                  'Settle',
                  isLoading: isSaving,
                  onTap: isSaving ? null : _settle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modeButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(7, 10, 27, 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade800,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$value';
  }
}
