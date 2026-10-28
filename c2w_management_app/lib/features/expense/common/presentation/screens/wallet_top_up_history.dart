import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/wallet_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTopUpHistory extends StatefulWidget {
  const WalletTopUpHistory({super.key});

  @override
  State<WalletTopUpHistory> createState() => _WalletTopUpHistoryState();
}

class _WalletTopUpHistoryState extends State<WalletTopUpHistory> {
  late Future<WalletFinancialSummary> _summary;

  @override
  void initState() {
    super.initState();
    _summary = canTopUpWallet()
        ? context.read<WalletBloc>().getWalletFinancialSummary()
        : Future.error('Only SuperAdmin can view wallet financial summary.');
  }

  void _reload() {
    setState(() {
      _summary = context.read<WalletBloc>().getWalletFinancialSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!canTopUpWallet()) {
      return const Scaffold(
        body: Center(
          child: Text('Only SuperAdmin can view wallet top-up history.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        title: const Text(
          'Wallet Summary',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh summary',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<WalletFinancialSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load wallet summary: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(onPressed: _reload, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final summary = snapshot.data!;
          final companies = [
            'Incubators',
            'Core2web',
            'Both',
            if (summary.companyTotals.containsKey('Unassigned')) 'Unassigned',
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(
                title: 'Remaining Wallet Balance',
                amount: summary.currentBalance,
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF16C784),
              ),
              const SizedBox(height: 10),
              _summaryCard(
                title: 'Total Added to Wallet',
                amount: summary.totalTopUps,
                icon: Icons.add_circle_outline,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 10),
              _summaryCard(
                title: 'Expenses Submitted',
                amount: summary.totalExpenses,
                icon: Icons.receipt_long,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 10),
              _summaryCard(
                title: 'Total Distributed from Wallet',
                amount: summary.totalWalletFundedExpenses,
                icon: Icons.outbound,
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Company-wise Expenses Submitted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final company in companies)
                _companyCard(
                  company,
                  summary.companyTotals[company],
                  summary.companyExpenses[company] ?? const [],
                ),
              const SizedBox(height: 24),
              const Text(
                'Top-up History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (summary.topUpHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No wallet top-ups yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                for (final entry in summary.topUpHistory) _topUpCard(entry),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: AppTheme().appBarBackgroundColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          _formatAmount(amount),
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _companyCard(
    String company,
    CompanyExpenseTotals? totals,
    List<Map<String, dynamic>> transactions,
  ) {
    return Card(
      color: AppTheme().appBarBackgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => _CompanyExpenseTransactionsPage(
                company: company,
                transactions: transactions,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      company,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 10),
              _amountRow('Expenses submitted', totals?.totalExpenses ?? 0),
              const SizedBox(height: 6),
              _amountRow('Paid from wallet', totals?.walletFundedExpenses ?? 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          _formatAmount(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _topUpCard(Map<String, dynamic> entry) {
    final createdAt = entry['createdAt'];
    final dateText = createdAt is Timestamp
        ? _formatDate(createdAt.toDate())
        : 'Date unavailable';
    return Card(
      color: AppTheme().appBarBackgroundColor,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF163B32),
          child: Icon(Icons.add, color: Color(0xFF16C784)),
        ),
        title: Text(
          _formatAmount(_amount(entry['amount'])),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$dateText\nAdded by ${entry['createdBy']?.toString() ?? 'Unknown'}',
          style: const TextStyle(color: Colors.white70),
        ),
        isThreeLine: true,
      ),
    );
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹ $value';
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final minute = localDate.minute.toString().padLeft(2, '0');
    final period = localDate.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/${localDate.year}, $hour:$minute $period';
  }
}

class _CompanyExpenseTransactionsPage extends StatelessWidget {
  const _CompanyExpenseTransactionsPage({
    required this.company,
    required this.transactions,
  });

  final String company;
  final List<Map<String, dynamic>> transactions;

  @override
  Widget build(BuildContext context) {
    if (!canTopUpWallet()) {
      return const Scaffold(
        body: Center(child: Text('Only SuperAdmin can view company expenses.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        title: Text(
          '$company Expenses',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'No transactions for this company yet.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : MonthwiseIndividualListview().getExpenseHistoryListview(
              transactions,
            ),
    );
  }
}
