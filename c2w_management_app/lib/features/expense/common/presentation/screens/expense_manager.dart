import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/manage_categories.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/memberslist.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/transaction_details.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/view_all_expenses.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/wallet_screen.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/colorlist.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/floating_button.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseManager extends StatefulWidget {
  const ExpenseManager({super.key});

  @override
  State<ExpenseManager> createState() => _ExpenseManagerState();
}

class _ExpenseManagerState extends State<ExpenseManager> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['This Week', 'This Month', 'This Year'];

  Future<void> _refreshExpenses() {
    final bloc = context.read<ExpenseManagerBloc>();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadExpenseManagerData()),
      isComplete: (state) =>
          state is ExpenseManagerDataLoaded || state is ExpenseManagerFailure,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ExpenseManagerBloc>().add(LoadExpenseManagerData());
    context.read<ExpenseCategoryBloc>().add(LoadExpenseCategories());
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1424);
    const cardColor = Color(0xFF1E2638);
    final categoryState = context.watch<ExpenseCategoryBloc>().state;

    return BlocBuilder<ExpenseManagerBloc, Object>(
      builder: (context, state) {
        if (state is ExpenseManagerInitial || state is ExpenseManagerLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F1424),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            ),
          );
        }

        if (state is ExpenseManagerFailure) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load expense data: ${state.message}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<ExpenseManagerBloc>().add(
                        LoadExpenseManagerData(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! ExpenseManagerDataLoaded) {
          return const SizedBox.shrink();
        }

        final expenses = _filterExpenses(state.expenses);
        final totalAmount = expenses.fold<double>(
          0,
          (runningTotal, expense) =>
              runningTotal + _expenseAmount(expense['amount']),
        );
        final paidAmount = expenses
            .where(
              (expense) =>
                  expense['status']?.toString().toLowerCase() == 'settled',
            )
            .fold<double>(
              0,
              (runningTotal, expense) =>
                  runningTotal + _expenseAmount(expense['amount']),
            );
        final unpaidAmount = totalAmount - paidAmount;
        final recentExpenses = expenses.take(5).toList();

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            //leading: Icon(Icons.arrow_back, color: Colors.white),
            title: Text(
              "Expense Manager",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color.fromRGBO(31, 34, 49, 1),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WalletScreen()),
                  );
                },
                child: Icon(Icons.account_balance_wallet, color: Colors.amber),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshExpenses,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(31, 34, 49, 1),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(53, 56, 69, 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _selectedFilterIndex = _filters.indexOf(
                                      "This Week",
                                    );
                                    setState(() {});
                                  },

                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.sizeOf(context).width / 3,
                                    decoration: BoxDecoration(
                                      color: (_selectedFilterIndex == 0)
                                          ? Colors.blue
                                          : Color.fromRGBO(53, 56, 69, 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "This Week",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight(600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _selectedFilterIndex = _filters.indexOf(
                                      "This Month",
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.sizeOf(context).width / 3,
                                    decoration: BoxDecoration(
                                      color: (_selectedFilterIndex == 1)
                                          ? Colors.blue
                                          : Color.fromRGBO(53, 56, 69, 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "This Month",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight(600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _selectedFilterIndex = _filters.indexOf(
                                      "This Year",
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.sizeOf(context).width / 3,
                                    decoration: BoxDecoration(
                                      color: (_selectedFilterIndex == 2)
                                          ? Colors.blue
                                          : Color.fromRGBO(53, 56, 69, 1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "This Year",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight(600),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 100,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Paid Amount',
                                value: _formatAmount(paidAmount),
                                icon: Icons.trending_up,
                                iconColor: const Color(0xFF00D09C),
                                iconBgColor: const Color(0xFF0D3838),
                                cardBg: cardColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: _buildMetricCard(
                                  title: 'Unpaid Amount',
                                  value: _formatAmount(unpaidAmount),
                                  icon: Icons.trending_down,
                                  iconColor: const Color(0xFFFF5271),
                                  iconBgColor: const Color(0xFF3E1D2D),
                                  cardBg: cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Positioned(
                        top: 200,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            if (canManageExpenseCategories()) ...[
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ManageCategories(),
                                      ),
                                    );
                                  },
                                  child: _buildMetricCard(
                                    title: 'Categories',
                                    value:
                                        categoryState is ExpenseCategoryLoaded
                                        ? categoryState.categories.length
                                              .toString()
                                        : '—',
                                    icon: Icons.check_circle_outline,
                                    iconColor: Color.fromRGBO(252, 174, 16, 1),
                                    iconBgColor: Color.fromRGBO(
                                      252,
                                      174,
                                      16,
                                      0.2,
                                    ),
                                    cardBg: cardColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MembersList(),
                                    ),
                                  );
                                },
                                child: _buildMetricCard(
                                  title: 'Members',
                                  value: state.memberCount.toString(),
                                  icon: Icons.person_outline,
                                  iconColor: Color.fromRGBO(5, 165, 255, 1),
                                  iconBgColor: const Color(0xFF143048),
                                  cardBg: cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        "Recent Transactions",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight(500),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewAllExpenses(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "See all",
                              style: TextStyle(
                                color: Color.fromRGBO(5, 165, 255, 1),
                                fontSize: 14,
                                fontWeight: FontWeight(500),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Color.fromRGBO(5, 165, 255, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    itemCount: recentExpenses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final expense = recentExpenses[index];
                      final name =
                          expense['claimantName']?.toString() ??
                          'Unknown member';
                      final trimmedName = name.trim();
                      final initial = trimmedName.isEmpty
                          ? 'M'
                          : trimmedName[0].toUpperCase();
                      final description =
                          expense['description']?.toString().trim() ?? '';
                      final category = expense['category']?.toString() ?? '';
                      final date = _expenseDate(expense);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetails(expense),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: const Color.fromRGBO(15, 20, 36, 1),
                          child: Row(
                            children: [
                              // avatar circle
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: ColorList().colorForIndex(index),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF202435),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      description.isEmpty
                                          ? category
                                          : description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color.fromRGBO(126, 139, 155, 1),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: 90,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatAmount(
                                        _expenseAmount(expense['amount']),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      date == null
                                          ? '—'
                                          : '${date.day} ${_shortMonthName(date.month)}',
                                      style: TextStyle(
                                        color: Color.fromRGBO(126, 139, 155, 1),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingButton.getFloatingButton(),
          //bottomNavigationBar: CommonBottomNavigationBar(currentIndex: , onTap: onTap),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterExpenses(
    List<Map<String, dynamic>> expenses,
  ) {
    final now = DateTime.now();
    return expenses.where((expense) {
      final date = _expenseDate(expense);
      if (date == null) return false;

      switch (_selectedFilterIndex) {
        case 0:
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
          );
          final startOfNextWeek = startOfWeek.add(const Duration(days: 7));
          return !date.isBefore(startOfWeek) && date.isBefore(startOfNextWeek);
        case 1:
          return date.year == now.year && date.month == now.month;
        case 2:
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  DateTime? _expenseDate(Map<String, dynamic> expense) {
    final value = expense['expenseDate'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    final submittedAt = expense['submittedAt'];
    if (submittedAt is Timestamp) return submittedAt.toDate();
    return null;
  }

  double _expenseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$formatted';
  }

  String _shortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}
