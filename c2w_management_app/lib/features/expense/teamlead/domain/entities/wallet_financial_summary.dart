class CompanyExpenseTotals {
  final double totalExpenses;
  final double walletFundedExpenses;

  const CompanyExpenseTotals({
    required this.totalExpenses,
    required this.walletFundedExpenses,
  });
}

class WalletFinancialSummary {
  final double currentBalance;
  final double totalTopUps;
  final Map<String, CompanyExpenseTotals> companyTotals;
  final Map<String, List<Map<String, dynamic>>> companyExpenses;
  final List<Map<String, dynamic>> topUpHistory;

  const WalletFinancialSummary({
    required this.currentBalance,
    required this.totalTopUps,
    required this.companyTotals,
    required this.companyExpenses,
    required this.topUpHistory,
  });

  double get totalExpenses => companyTotals.values.fold(
    0,
    (total, company) => total + company.totalExpenses,
  );

  double get totalWalletFundedExpenses => companyTotals.values.fold(
    0,
    (total, company) => total + company.walletFundedExpenses,
  );
}
