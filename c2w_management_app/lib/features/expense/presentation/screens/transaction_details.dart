import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/utils/reload_after_event.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionDetails extends StatefulWidget {
  final Map<String, dynamic> expense;
  const TransactionDetails(this.expense, {super.key});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  bool _settledLocally = false;
  late Map<String, dynamic> _expense;

  @override
  void initState() {
    super.initState();
    _expense = Map<String, dynamic>.from(widget.expense);
  }

  bool get _isSettled =>
      _settledLocally ||
      _expense['status']?.toString().trim().toLowerCase() == 'settled';

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
            _settledLocally = false;
          });
          return;
        }
      }
    }
  }

  Future<void> _onActionTap() async {
    if (_isSettled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This transaction is already settled.')),
      );
      return;
    }

    if (canSettleWalletExpenses()) {
      final settled = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme().appBarBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (context) => BottomsheetSettle().getBottomSheetOpen(_expense),
      );
      if (settled == true && mounted) {
        setState(() => _settledLocally = true);
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewTransaction()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 194, 187, 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _expense['claimantName'],
                  style: GoogleFonts.figtree(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight(500),
                  ),
                ),
                Text(
                  (_expense['amount'].toString()),
                  style: GoogleFonts.poppins(
                    color: _isSettled
                        ? Colors.green
                        : Color.fromRGBO(255, 77, 106, 1),
                    fontSize: 32,
                    fontWeight: FontWeight(600),
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
                        _expense['expenseDate'].toString(),
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight(500),
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
                        child: Image.network(_expense['receiptUrl']),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SettleButton().getSettleButton(
                  context,
                  _isSettled
                      ? 'Already Settled'
                      : canSettleWalletExpenses()
                      ? 'Settle'
                      : AuthRepository.authEmail?.contains('mentor') == true ||
                            AuthRepository.authEmail?.contains('teamlead') ==
                                true
                      ? 'Edit'
                      : 'Settle',
                  onTap: _onActionTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
