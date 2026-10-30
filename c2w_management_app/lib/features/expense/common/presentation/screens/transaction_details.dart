import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/settle_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionDetails extends StatefulWidget {
  final Map<String, dynamic> expense;
  const TransactionDetails(this.expense, {super.key});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  late Map<String, dynamic> _expense;

  @override
  void initState() {
    super.initState();
    _expense = Map<String, dynamic>.from(widget.expense);
  }

  double get _totalAmount {
    final value = _expense['amount'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double get _settledAmount {
    if (_isPrepaid) return _totalAmount;
    final value = _expense['settledAmount'];
    final settled = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ??
              (_expense['status']?.toString().trim().toLowerCase() == 'settled'
                  ? _totalAmount
                  : 0);
    return settled.clamp(0, _totalAmount);
  }

  double get _remainingAmount =>
      (_totalAmount - _settledAmount).clamp(0, _totalAmount);

  bool get _isSettled => _remainingAmount == 0 && _totalAmount > 0;
  bool get _isPrepaid =>
      _expense['source']?.toString().trim().toLowerCase() == 'prepaid';
  String get _paymentSourceLabel =>
      _isPrepaid ? 'Prepaid' : 'Paid from Wallet';

  bool get _canEditAnyExpense => canSettleWalletExpenses();

  bool get _canEditOwnExpense {
    final email = AuthRepository.authEmail?.toLowerCase() ?? '';
    return email.startsWith('mentor_') || email.startsWith('teamlead_');
  }

  Future<void> _refreshExpense() async {
    final bloc = context.read<WalletBloc>();
    await reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadWallet()),
      isComplete: (state) =>
          state.runtimeType == WalletLoaded || state is WalletLoadFailure,
    );
    final currentState = bloc.state;
    final expenseId = _expense['id']?.toString();
    if (currentState is WalletLoaded && expenseId != null) {
      for (final expense in currentState.expenses) {
        if (expense['id']?.toString() == expenseId) {
          if (!mounted) return;
          setState(() {
            _expense = {..._expense, ...expense};
          });
          return;
        }
      }
    }
  }

  Future<void> _onActionTap() async {
    if (_isPrepaid) return;
    if (_isSettled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This transaction is already settled.')),
      );
      return;
    }

    final settled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme().appBarBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => BottomsheetSettle().getBottomSheetOpen({
        ..._expense,
        'remainingAmount': _remainingAmount,
      }),
    );
    if (settled == true && mounted) await _refreshExpense();
  }

  Future<void> _onEditTap() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewTransaction(expense: _expense),
      ),
    );
    if (updated == true && mounted) {
      await _refreshExpense();
    }
  }

  Future<void> _showReceipt(String receiptUrl) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: MediaQuery.of(dialogContext).size.width,
          height: MediaQuery.of(dialogContext).size.height * 0.8,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    receiptUrl,
                    width: MediaQuery.of(dialogContext).size.width,
                    height: MediaQuery.of(dialogContext).size.height * 0.8,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text(
                        'Unable to load receipt.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: 'Close receipt',
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimantName = _expense['claimantName']?.toString() ?? 'Member';
    final profileImage = _expense['profileImage']?.toString().trim() ?? '';
    final receiptUrl = _expense['receiptUrl']?.toString().trim() ?? '';

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Transactions Details",
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight(600),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshExpense,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromRGBO(255, 194, 187, 1),
                  child: profileImage.isEmpty
                      ? _claimantInitial(claimantName)
                      : ClipOval(
                          child: Image.network(
                            profileImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _claimantInitial(claimantName),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  claimantName,
                  style: GoogleFonts.figtree(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight(500),
                  ),
                ),
                Text(
                  _formatAmount(_totalAmount),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (_isPrepaid
                            ? const Color(0xFFB69CFF)
                            : const Color(0xFFFFC857))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _paymentSourceLabel,
                    style: TextStyle(
                      color: _isPrepaid
                          ? const Color(0xFFB69CFF)
                          : const Color(0xFFFFC857),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_settledAmount > 0)
                  Text(
                    'Settled: ${_formatAmount(_settledAmount)}',
                    style: const TextStyle(
                      color: Color(0xFF00D09C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (_remainingAmount > 0)
                  Text(
                    'Remaining: ${_formatAmount(_remainingAmount)}',
                    style: const TextStyle(
                      color: Color(0xFFFF5271),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: AppTheme().appBarBackgroundColor,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Date & Time",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      SizedBox(height: 10),

                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(
                          (_expense['expenseDate'] as Timestamp)
                              .toDate()
                              .toLocal(),
                        ),
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),

                      Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                      SizedBox(height: 10),
                      Text(
                        "Category",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _expense['category'],
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight(500),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                      SizedBox(height: 10),
                      Text(
                        "Sub-category",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _expense['subCategory'],
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight(500),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                      SizedBox(height: 10),
                      Text(
                        "Details",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _expense['description'],
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight(500),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                      SizedBox(height: 10),
                      Text(
                        "Photo Attachments",
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: receiptUrl.isEmpty
                            ? const Icon(
                                Icons.receipt_long,
                                color: Colors.black54,
                              )
                            : InkWell(
                                onTap: () => _showReceipt(receiptUrl),
                                child: Image.network(
                                  receiptUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                if (_canEditAnyExpense) _buildSettlementHistory(),
                const SizedBox(height: 20),
                if (_canEditAnyExpense && _isPrepaid)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _onEditTap,
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else if (_canEditAnyExpense)
                  Container(
                    height: 100,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    color: AppTheme().appBarBackgroundColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _onEditTap,
                            child: Text(
                              'Edit',
                              style: GoogleFonts.figtree(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.blue,
                              ),
                            ),
                            onPressed: _isSettled ? null : _onActionTap,
                            child: Text(
                              _isSettled ? 'Already Settled' : 'Settle',
                              style: GoogleFonts.figtree(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_canEditOwnExpense)
                  SettleButton().getSettleButton(
                    context,
                    'Edit',
                    onTap: _onEditTap,
                  )
                else if (!_isPrepaid)
                  SettleButton().getSettleButton(
                    context,
                    _isSettled ? 'Already Settled' : 'Settle',
                    onTap: _onActionTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _claimantInitial(String name) {
    return Text(
      name.isEmpty ? 'M' : name[0].toUpperCase(),
      style: GoogleFonts.figtree(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatAmount(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$value';
  }

  Widget _buildSettlementHistory() {
    final expenseId = _expense['id']?.toString();
    if (expenseId == null || expenseId.isEmpty) return const SizedBox.shrink();
    final historyStream = FirebaseFirestore.instance
        .collection('expenses')
        .doc(expenseId)
        .collection('settlements')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Container(
      width: MediaQuery.of(context).size.width - 30,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme().appBarBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C374B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settlement history',
            style: GoogleFonts.figtree(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: historyStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Could not load settlement history: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }
              final records = snapshot.data!.docs;
              if (records.isEmpty) {
                return const Text(
                  'No settlement history recorded.',
                  style: TextStyle(color: Colors.white60),
                );
              }
              return Column(
                children: records.map((record) {
                  final settlement = record.data();
                  final amountPaise = settlement['amountPaise'];
                  final amount = amountPaise is num
                      ? amountPaise.toDouble() / 100
                      : (double.tryParse(amountPaise?.toString() ?? '') ?? 0) /
                            100;
                  final settledBy =
                      settlement['settledByName']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? settlement['settledByName'].toString().trim()
                      : settlement['settledByEmail']?.toString() ?? 'Admin';
                  final source =
                      settlement['settlementSource']?.toString() ?? 'Manual';
                  final createdAt = settlement['createdAt'];
                  final date = createdAt is Timestamp
                      ? createdAt.toDate()
                      : createdAt is DateTime
                      ? createdAt
                      : null;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF00D09C),
                    ),
                    title: Text(
                      '${_formatAmount(amount)} • $source',
                      style: const TextStyle(
                        color: Color(0xFF00D09C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Settled by $settledBy${date == null ? '' : ' • ${DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal())}'}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
