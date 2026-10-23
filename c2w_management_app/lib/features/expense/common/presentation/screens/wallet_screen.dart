import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Future<void> _refreshWallet() {
    final bloc = context.read<WalletBloc>();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadWallet()),
      isComplete: (state) =>
          state.runtimeType == WalletLoaded || state is WalletLoadFailure,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWallet());
  }

  Future<void> _showTopUpDialog() async {
    final controller = TextEditingController();
    String? error;
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme().appBarBackgroundColor,
          title: const Text(
            'Top-up Wallet',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            cursorColor: Colors.white,
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: Colors.white),
              hintText: 'Enter amount',
              hintStyle: const TextStyle(color: Colors.white54),
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green),
              ),
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value == null || value <= 0) {
                  setDialogState(() => error = 'Enter a valid amount.');
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    controller.clear();
    if (amount != null && mounted) {
      context.read<WalletBloc>().add(AddWalletTopUp(amount));
    }
  }

  Future<void> _openSettlement(Map<String, dynamic> expense) async {
    if (expense['status']?.toString().toLowerCase() == 'settled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This transaction is already settled.')),
      );
      return;
    }
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme().appBarBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => BottomsheetSettle().getBottomSheetOpen(expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletActionSuccess &&
            state.action == WalletActionKind.topUp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet updated successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is WalletActionFailure &&
            state.action == WalletActionKind.topUp &&
            (ModalRoute.of(context)?.isCurrent ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final balance = state is WalletLoaded ? state.balance : null;
        final expenses = state is WalletLoaded ? state.expenses : null;

        return Scaffold(
          backgroundColor: const Color(0xFF080B1B),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(220),
            child: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 220,
              titleSpacing: 0,
              backgroundColor: const Color.fromRGBO(32, 34, 58, 1),
              elevation: 0,
              title: Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(32, 34, 58, 1),
                      Color.fromRGBO(32, 34, 58, 1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (canTopUpWallet())
                            ElevatedButton.icon(
                              onPressed: state is WalletActionInProgress
                                  ? null
                                  : _showTopUpDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                'Top-up',
                                style: GoogleFonts.figtree(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    if (state is WalletLoading || balance == null)
                      const SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                    else
                      Text(
                        _formatAmount(balance),
                        style: const TextStyle(
                          color: Color(0xFF16C784),
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 10,
                      top: 20,
                      bottom: 10,
                    ),
                    child: Container(
                      height: 45,
                      width: 140,
                      decoration: BoxDecoration(
                        color: AppTheme().appBarBackgroundColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'All Categories',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 20,
                      bottom: 10,
                    ),
                    child: Container(
                      height: 45,
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppTheme().appBarBackgroundColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'dd-mm-yyyy',
                          style: GoogleFonts.figtree(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(child: _walletExpenseContent(state, expenses)),
            ],
          ),
        );
      },
    );
  }

  Widget _walletExpenseContent(
    WalletState state,
    List<Map<String, dynamic>>? expenses,
  ) {
    if (state is WalletLoading || state is WalletInitial) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (state is WalletLoadFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => context.read<WalletBloc>().add(LoadWallet()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (expenses == null || expenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshWallet,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  'No transactions available.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshWallet,
      child: MonthwiseIndividualListview().getExpenseHistoryListview(
        expenses,
        onTransactionTap: (expense) {
          if (canSettleWalletExpenses()) {
            _openSettlement(expense);
          }
        },
      ),
    );
  }

  String _formatAmount(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹ $value';
  }
}
