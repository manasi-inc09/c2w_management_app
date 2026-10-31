import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/wallet_screen.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/manage_categories.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/memberslist.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/transaction_details.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/view_all_expenses.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/event_expense_groups.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/transaction_deletion.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/colorlist.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/floating_button.dart';

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
        final paidAmount = expenses.fold<double>(0, (runningTotal, expense) {
          return runningTotal +
              _settledExpenseAmount(expense, _expenseAmount(expense['amount']));
        });
        final unpaidAmount = totalAmount - paidAmount;
        final prepaidAmount = expenses.fold<double>(
          0,
          (total, expense) => total + _sourceAmount(expense, 'Prepaid'),
        );
        final walletAmount = expenses.fold<double>(
          0,
          (total, expense) => total + _sourceAmount(expense, 'Wallet'),
        );
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
              IconButton(
                tooltip: 'Event expenses',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EventExpenseGroupsScreen(),
                  ),
                ),
                icon: const Icon(Icons.groups_outlined, color: Colors.white),
              ),
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
                                valueColor: const Color(0xFF00D09C),
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
                                  valueColor: const Color(0xFFFF5271),
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expense source totals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSourceSummary(
                              'Wallet',
                              walletAmount,
                              const Color(0xFFFFC857),
                            ),
                            _buildSourceSummary(
                              'Prepaid',
                              prepaidAmount,
                              const Color(0xFFB69CFF),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      final isGroupExpense =
                          expense['eventExpenseGroup'] == true;
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
                      final paymentSource = _paymentSourceLabel(
                        isGroupExpense ? null : expense['source']?.toString(),
                      );
                      final date = _expenseDate(expense);
                      final total = _expenseAmount(expense['amount']);
                      final settled = _settledExpenseAmount(expense, total);
                      final remaining = (total - settled)
                          .clamp(0, total)
                          .toDouble();
                      final transactionCard = GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => isGroupExpense
                                  ? EventExpenseGroupDetailsScreen(
                                      groupId: expense['groupId'].toString(),
                                    )
                                  : TransactionDetails(expense),
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
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          isGroupExpense
                                              ? 'Group Expense • $description'
                                              : description.isEmpty
                                              ? category
                                              : description,
                                          style: const TextStyle(
                                            color: Color.fromRGBO(
                                              126,
                                              139,
                                              155,
                                              1,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (isGroupExpense)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF143048),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              expense['groupName']
                                                      ?.toString() ??
                                                  'Event group',
                                              style: const TextStyle(
                                                color: Color(0xFF8CCBFF),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        if (isGroupExpense &&
                                            _expenseAmount(
                                                  expense['walletAmount'],
                                                ) >
                                                0)
                                          _buildGroupSourceTag(
                                            'Paid from Wallet',
                                            _expenseAmount(
                                              expense['walletAmount'],
                                            ),
                                            const Color(0xFFFFC857),
                                          ),
                                        if (isGroupExpense &&
                                            _expenseAmount(
                                                  expense['prepaidAmount'],
                                                ) >
                                                0)
                                          _buildGroupSourceTag(
                                            'Prepaid',
                                            _expenseAmount(
                                              expense['prepaidAmount'],
                                            ),
                                            const Color(0xFFB69CFF),
                                          ),
                                        if (paymentSource != null)
                                          _buildGroupSourceTag(
                                            paymentSource,
                                            0,
                                            paymentSource == 'Prepaid'
                                                ? const Color(0xFFB69CFF)
                                                : const Color(0xFFFFC857),
                                            includeAmount: false,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(
                                width: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatAmount(total),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (settled > 0)
                                      Text(
                                        '+${_formatAmount(settled)} paid',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF00D09C),
                                          fontSize: 10,
                                        ),
                                      ),
                                    if (remaining > 0)
                                      Text(
                                        '${_formatAmount(remaining)} left',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFFF5271),
                                          fontSize: 10,
                                        ),
                                      ),
                                    const SizedBox(height: 2),
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
                      if (!canDeleteExpenseTransaction(expense)) {
                        return transactionCard;
                      }

                      final expenseId = expense['id']?.toString();
                      return Dismissible(
                        key: ValueKey(
                          expenseId?.isNotEmpty == true
                              ? expenseId
                              : 'recent-expense-$index',
                        ),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (_) async {
                          final deleted =
                              await deleteExpenseTransactionWithReason(
                                context,
                                expense,
                              );
                          if (deleted && mounted) await _refreshExpenses();
                          return deleted;
                        },
                        background: _deleteSwipeBackground(
                          alignment: Alignment.centerLeft,
                        ),
                        secondaryBackground: _deleteSwipeBackground(
                          alignment: Alignment.centerRight,
                        ),
                        child: transactionCard,
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

  Widget _deleteSwipeBackground({required Alignment alignment}) {
    return Container(
      color: Colors.redAccent,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
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

  double _settledExpenseAmount(
    Map<String, dynamic> expense,
    double totalAmount,
  ) {
    final value = expense['settledAmount'];
    if (value is num) return value.toDouble().clamp(0, totalAmount);
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed.clamp(0, totalAmount);
    return expense['status']?.toString().toLowerCase() == 'settled'
        ? totalAmount
        : 0;
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
    Color valueColor = Colors.white,
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
                  style: TextStyle(
                    color: valueColor,
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

  double _sourceAmount(Map<String, dynamic> expense, String source) {
    if (expense['eventExpenseGroup'] == true) {
      final field = source == 'Prepaid'
          ? 'prepaidAmount'
          : source == 'Wallet'
          ? 'walletAmount'
          : null;
      return field == null ? 0 : _expenseAmount(expense[field]);
    }

    final expenseSource = expense['source']?.toString().trim();
    if (source == 'Wallet') {
      return expenseSource?.toLowerCase() == 'wallet' ||
              expenseSource?.toLowerCase() == 'self paid' ||
              expenseSource == null ||
              expenseSource.isEmpty
          ? _expenseAmount(expense['amount'])
          : 0;
    }
    return expenseSource?.toLowerCase() == source.toLowerCase()
        ? _expenseAmount(expense['amount'])
        : 0;
  }

  Widget _buildSourceSummary(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAmount(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String? _paymentSourceLabel(String? source) {
    switch (source?.trim().toLowerCase()) {
      case 'prepaid':
        return 'Prepaid';
      case 'wallet':
      case 'self paid':
        return 'Paid from Wallet';
      default:
        return 'Paid from Wallet';
    }
  }

  Widget _buildGroupSourceTag(
    String label,
    double amount,
    Color color, {
    bool includeAmount = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        includeAmount ? '$label ${_formatAmount(amount)}' : label,
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}
