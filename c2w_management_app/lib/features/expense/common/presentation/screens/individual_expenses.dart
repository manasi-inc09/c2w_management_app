import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/expense_manager.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/settle_button.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_history_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class IndividualExpenses extends StatefulWidget {
  final bool showOnlyMyTransactions;

  const IndividualExpenses({super.key, this.showOnlyMyTransactions = false});

  @override
  State<IndividualExpenses> createState() => _IndividualExpensesState();
}

class _IndividualExpensesState extends State<IndividualExpenses> {
  late final ExpenseFilterBloc _expenseFilterBloc;
  String selectedOption = "Option 1";
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  //List<String> individualFilterList = ["Event |  dsdsCPL event", "Subodh"];
  //List<String> filterList=["Categories","Members","dd-mm-yyyy"];
  Map<String, String> appliedFilters = {};

  String? get _authenticatedEmail =>
      FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail;

  String? get _authRole {
    final email = _authenticatedEmail;
    if (email == null) return null;
    for (final role in ['teamlead', 'mentor', 'instructor', 'superadmin']) {
      if (email.startsWith('${role}_')) return role;
    }
    return null;
  }

  String? get _profileEmail {
    final email = _authenticatedEmail;
    final role = _authRole;
    if (email == null || email.isEmpty) return null;
    if (role == null) return email;
    return email.substring(role.length + 1);
  }

  Future<void> _refreshHistory() {
    final email = _profileEmail;
    final bloc = context.read<ExpenseHistoryBloc>();
    final role = _authRole;
    if (role == 'superadmin') {
      return reloadAfterEvent(
        states: bloc.stream,
        dispatch: () => bloc.add(LoadExpensesByEmail(email!)),
        isComplete: (state) =>
            state is ExpenseHistoryLoaded || state is ExpenseHistoryFailure,
      );
    }
    //final email = _profileEmail;
    if (email == null || email.isEmpty) return Future.value();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadExpensesByEmail(email)),
      isComplete: (state) =>
          state is ExpenseHistoryLoaded || state is ExpenseHistoryFailure,
    );
  }

  @override
  void dispose() {
    _expenseFilterBloc.add(ResetExpenseFilters());
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _matchesExpenseSearch(Map<String, dynamic> expense) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      expense['claimantName'],
      expense['description'],
      expense['category'],
      expense['subCategory'],
      expense['source'],
      expense['amount'],
      expense['email'],
    ].any((value) => value?.toString().toLowerCase().contains(query) ?? false);
  }

  @override
  void initState() {
    super.initState();
    _expenseFilterBloc = context.read<ExpenseFilterBloc>();
    _expenseFilterBloc.add(ResetExpenseFilters());
    final role = _authRole;
    if (widget.showOnlyMyTransactions) {
      final email = _profileEmail;
      if (email != null && email.isNotEmpty) {
        context.read<ExpenseHistoryBloc>().add(LoadExpensesByEmail(email));
      }
      return;
    }

    if (role == 'superadmin') {
      context.read<ExpenseHistoryBloc>().add(LoadAllExpenses());
    } else if (['teamlead', 'mentor', 'instructor'].contains(role)) {
      final email = _profileEmail;
      if (email != null && email.isNotEmpty) {
        context.read<ExpenseHistoryBloc>().add(LoadExpensesByEmail(email));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _authRole;
    final hasLiveHistory = [
      'teamlead',
      'mentor',
      'instructor',
      'superadmin',
    ].contains(role);
    final canCreateExpense = [
      'teamlead',
      'mentor',
      'instructor',
    ].contains(role);

    return Scaffold(
      backgroundColor: AppTheme().appBarBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,

        leading: (role == 'instructor' || role == 'superadmin')
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : SizedBox(),

        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Search transactions',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

        actions: [
          IconButton(
            onPressed: _isSearching
                ? _toggleSearch
                : () => setState(() => _isSearching = true),
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_outlined,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.06),
              shape: const CircleBorder(
                side: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1)),
              ),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          const SizedBox(width: 15),
        ],
        bottom: CommonFilters().getCommonFilter(context),
      ),
      body: Column(
        children: [
          BlocBuilder<ExpenseHistoryBloc, ExpenseHistoryState>(
            builder: (context, state) {
              var total = hasLiveHistory ? 0.0 : 8590.0;
              var settled = 0.0;
              if (state is ExpenseHistoryLoaded) {
                final expenses = filterExpenses(
                  state.expenses,
                  canUseExpenseFilters()
                      ? context.watch<ExpenseFilterBloc>().state.selection
                      : const ExpenseFilterSelection(),
                  currentEmail: _authenticatedEmail,
                ).where(_matchesExpenseSearch).toList();
                total = expenses.fold<double>(
                  0,
                  (sum, expense) => sum + _expenseAmount(expense),
                );
                settled = expenses
                    .where(
                      (expense) =>
                          expense['status']?.toString().toLowerCase() ==
                          'settled',
                    )
                    .fold<double>(
                      0,
                      (sum, expense) => sum + _expenseAmount(expense),
                    );
              }
              return Row(
                children: [
                  _buildHistorySummary('Total', total),
                  Container(height: 65, width: 1, color: Colors.white24),
                  _buildHistorySummary(
                    'Settled',
                    settled,
                    amountColor: const Color.fromRGBO(28, 205, 128, 1),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: !hasLiveHistory
                ? const Center(
                    child: Text(
                      'No expense history available yet.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : role != 'superadmin' &&
                      (_profileEmail == null || _profileEmail!.isEmpty)
                ? const Center(
                    child: Text(
                      'Could not determine the account email.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : BlocBuilder<ExpenseHistoryBloc, ExpenseHistoryState>(
                    builder: (context, state) {
                      if (state is ExpenseHistoryInitial ||
                          state is ExpenseHistoryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2196F3),
                          ),
                        );
                      }
                      if (state is ExpenseHistoryFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Could not load transactions: ${state.message}',
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (state is ExpenseHistoryLoaded) {
                        final expenses = filterExpenses(
                          state.expenses,
                          canUseExpenseFilters()
                              ? context
                                    .watch<ExpenseFilterBloc>()
                                    .state
                                    .selection
                              : const ExpenseFilterSelection(),
                          currentEmail: _authenticatedEmail,
                        ).where(_matchesExpenseSearch).toList();
                        if (expenses.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: _refreshHistory,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      'No transactions yet.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: _refreshHistory,
                          child: MonthwiseIndividualListview()
                              .getExpenseHistoryListview(expenses),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SettleButton().getSettleButton(
        context,
        canCreateExpense ? 'Add Transaction' : 'Settle',
        container: !canCreateExpense && role == 'instructor'
            ? getBottomSheetOpen()
            : null,
        onTap: canCreateExpense
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateNewTransaction(),
                  ),
                );
              }
            : null,
      ),
    );
  }

  double _expenseAmount(Map<String, dynamic> expense) {
    final amount = expense['amount'];
    if (amount is num) return amount.toDouble();
    return double.tryParse(amount?.toString() ?? '') ?? 0;
  }

  Widget _buildHistorySummary(
    String label,
    double amount, {
    Color amountColor = Colors.white,
  }) {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    return Expanded(
      child: Container(
        height: 100,
        color: const Color.fromRGBO(7, 10, 27, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹$formatted',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: amountColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getExpensePage() {
    return const ExpenseManager();
  }

  void handleRadioChange(String? value) {
    if (value != null) {
      setState(() {
        selectedOption = value;
      });
    }
  }

  Widget getBottomSheetOpen() {
    String localSelectedOption = selectedOption;
    bool isChecked = false;

    return BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void handleCheckBox(bool? value) {
              if (value != null) {
                setState(() {
                  isChecked = value; // Update your state variable
                });
              }
            }

            // Helper widget to build each custom radio box
            Widget buildRadioBox({
              required String title,
              required String value,
            }) {
              bool isSelected = localSelectedOption == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      localSelectedOption = value;
                    });
                    this.setState(() {
                      selectedOption = value; // Update main page state
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                        7,
                        10,
                        27,
                        1,
                      ), // Dark container background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors
                                  .grey
                                  .shade800, // Blue border if selected, grey otherwise
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Custom Radio Circle Indicator
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppTheme()
                    .appBarBackgroundColor, // Sheet background color matching your theme
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag handle bar like in the image
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Row containing both option boxes side-by-side
                  Row(
                    children: [
                      buildRadioBox(title: "Total", value: "Option 1"),
                      const SizedBox(width: 12),
                      buildRadioBox(title: "Custom", value: "Option 2"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "8590",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  const SizedBox(height: 10),
                  Container(
                    height: 60,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(90, 36, 118, 1),
                          Color.fromRGBO(59, 46, 116, 1),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Settle from Wallet",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight(400),
                                  color: Colors.white,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "Available Balance: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "10,000",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight
                                            .w500, // Optional: slightly bolder for emphasis
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Checkbox(
                          value: isChecked,
                          onChanged: handleCheckBox,
                          activeColor: Colors.green,
                          side: BorderSide(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SettleButton().getSettleButton(
                    context,
                    (AuthRepository.authEmail!.contains("_instructor"))
                        ? "Settle"
                        : "Add Transaction",
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
