import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/transaction_details.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/colorlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonthwiseIndividualListview {
  Widget getExpenseHistoryListview(
    List<Map<String, dynamic>> transactions, {
    bool shrinkWrap = false,
    ValueChanged<Map<String, dynamic>>? onTransactionTap,
  }) {
    final grouped = <DateTime?, List<Map<String, dynamic>>>{};

    for (final transaction in transactions) {
      final date = _transactionDate(transaction);
      final month = date == null ? null : DateTime(date.year, date.month);
      grouped.putIfAbsent(month, () => []).add(transaction);
    }

    for (final monthTransactions in grouped.values) {
      monthTransactions.sort((first, second) {
        final firstDate = _transactionDate(first);
        final secondDate = _transactionDate(second);
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return secondDate.compareTo(firstDate);
      });
    }

    final months = grouped.keys.toList()
      ..sort((first, second) {
        if (first == null) return 1;
        if (second == null) return -1;
        return second.compareTo(first);
      });

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: months.length,
      itemBuilder: (context, groupIndex) {
        final month = months[groupIndex];
        final monthTransactions = grouped[month]!;
        final colorOffset = months
            .take(groupIndex)
            .fold<int>(0, (total, key) => total + grouped[key]!.length);
        final avatarColors = ColorList().colorList;
        final monthTotal = monthTransactions.fold<double>(
          0,
          (runningTotal, transaction) =>
              runningTotal + _transactionAmount(transaction),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppTheme().appBarBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        month == null ? '' : '${month.year}',
                        style: const TextStyle(
                          color: Color(0xFF7E8B9B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        month == null
                            ? 'Date unavailable'
                            : _monthName(month.month),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatAmount(monthTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...monthTransactions.asMap().entries.map((entry) {
              final transaction = entry.value;
              final settled =
                  transaction['status']?.toString().toLowerCase() == 'settled';
              final description =
                  transaction['description']?.toString().trim() ?? '';
              final category = transaction['category']?.toString() ?? '';
              final source = transaction['source']?.toString() ?? '';
              final date = _transactionDate(transaction);
              final title = description.isEmpty ? category : description;
              final initial = title.trim().isEmpty
                  ? 'T'
                  : title.trim()[0].toUpperCase();
              final avatarColor =
                  avatarColors[(colorOffset + entry.key) % avatarColors.length];
              final subtitle = [
                category,
                source,
              ].where((value) => value.isNotEmpty).join(' • ');

              return GestureDetector(
                onTap: () {
                  if (onTransactionTap != null) {
                    onTransactionTap(transaction);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetails(transaction),
                      ),
                    );
                  }
                },
                child: Opacity(
                  opacity: settled ? 0.42 : 1,
                  child: Container(
                    color: const Color.fromRGBO(7, 10, 27, 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: avatarColor,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Color(0xFF202435),
                              fontSize: 18,
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
                                title.isEmpty ? 'Transaction' : title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7E8B9B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatAmount(_transactionAmount(transaction)),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date == null
                                  ? '—'
                                  : '${date.day} ${_shortMonthName(date.month)}',
                              style: const TextStyle(
                                color: Color(0xFF7E8B9B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  static DateTime? _transactionDate(Map<String, dynamic> transaction) {
    final value = transaction['expenseDate'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    final submittedAt = transaction['submittedAt'];
    if (submittedAt is Timestamp) return submittedAt.toDate();
    return null;
  }

  static double _transactionAmount(Map<String, dynamic> transaction) {
    final value = transaction['amount'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatAmount(double amount) {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$formatted';
  }

  static String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  static String _shortMonthName(int month) {
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

  Widget getMonthwiseExpenseListview(
    List<Map<String, dynamic>> transactionData,
  ) {
    return ListView.builder(
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: transactionData.length,
      itemBuilder: (context, groupIndex) {
        final group = transactionData[groupIndex];
        final List items = group['transactions'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // month header
            Container(
              decoration: BoxDecoration(
                color: AppTheme().appBarBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['year'],
                          style: const TextStyle(
                            color: Color.fromRGBO(126, 139, 155, 1),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          group['month'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      group['totalAmount'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // items inside this month
            ...items.map((item) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetails(group),
                    ),
                  );
                },
                child: Container(
                  color: const Color.fromRGBO(7, 10, 27, 1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item['avatarBg'],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['initial'],
                          style: TextStyle(
                            color: item['avatarTextColor'],
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
                              item['title'], // Updated key from 'name' to 'title'
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['category'], // Updated key from 'subtitle' to 'category'
                              style: const TextStyle(
                                color: Color.fromRGBO(126, 139, 155, 1),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['amount'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'],
                            style: const TextStyle(
                              color: Color.fromRGBO(126, 139, 155, 1),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
