
class Expense {
  final DateTime expenseDate;
  final double amount;
  final String source;
  final String description;
  final String category;
  final String subCategory;
  final String? receiptLocalPath;

  const Expense({
    required this.expenseDate,
    required this.amount,
    required this.source,
    required this.description,
    required this.category,
    required this.subCategory,
    this.receiptLocalPath,
  });
}
