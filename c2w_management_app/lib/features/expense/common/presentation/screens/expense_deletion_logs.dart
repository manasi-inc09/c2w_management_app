import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_deletion_logs_bloc.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpenseDeletionLogsScreen extends StatelessWidget {
  const ExpenseDeletionLogsScreen({super.key});

  bool _isAuthorized() {
    final email =
        (FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail)
            ?.trim()
            .toLowerCase() ??
        '';
    return email.startsWith('instructor_') || email.startsWith('superadmin_');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized()) {
      return Scaffold(
        backgroundColor: AppTheme().bodyBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme().appBarBackgroundColor,
          title: const Text('Deletion logs'),
        ),
        body: const Center(
          child: Text(
            'Deletion logs are available to instructors and superadmins.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transaction deletion logs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocProvider(
        create: (_) =>
            ExpenseDeletionLogsBloc()..add(ExpenseDeletionLogsRequested()),
        child: BlocBuilder<ExpenseDeletionLogsBloc, ExpenseDeletionLogsState>(
          builder: (context, state) {
            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load deletion logs: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            final logs = state.logs;
            if (logs.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions have been deleted.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = logs[index];
                final details =
                    (log['transactionDetails'] as Map<String, dynamic>?) ??
                    const <String, dynamic>{};
                final isGroup =
                    log['transactionType']?.toString() == 'group_contribution';
                final amount = isGroup
                    ? _readAmount(details['amountPaise']) / 100
                    : _readAmount(details['amount']);
                final description =
                    details['description']?.toString().trim().isNotEmpty == true
                    ? details['description'].toString().trim()
                    : details['category']?.toString() ??
                          details['paymentType']?.toString() ??
                          'Transaction';
                final deletedAt = _readDate(log['deletedAt']);

                return Card(
                  color: const Color(0xFF1E2638),
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    iconColor: Colors.blue,
                    collapsedIconColor: Colors.white70,
                    title: Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB8DCFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _formatAmount(amount),
                            style: const TextStyle(
                              color: Color(0xFF72D6B2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' • ${deletedAt == null ? 'Date unavailable' : DateFormat('dd MMM yyyy, hh:mm a').format(deletedAt)}',
                            style: const TextStyle(color: Color(0xFFAAB6C8)),
                          ),
                        ],
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _detail('Deletion reason', log['reason']),
                      _detail(
                        'Deleted by',
                        '${log['deletedByName'] ?? 'Unknown'} (${log['deletedByRole'] ?? 'Unknown role'})',
                      ),
                      _detail('Account', log['deletedByEmail']),
                      _detail('Transaction ID', log['transactionId']),
                      _detail(
                        'Transaction type',
                        isGroup ? 'Group contribution' : 'Expense',
                      ),
                      if (isGroup) _detail('Event group', log['groupName']),
                      _detail(
                        'Claimant',
                        details['claimantName'] ?? details['createdByName'],
                      ),
                      _detail(
                        'Claimant email',
                        details['email'] ?? details['createdByEmail'],
                      ),
                      _detail('Amount', _formatAmount(amount)),
                      _detail(
                        'Category / purpose',
                        details['category'] ?? details['paymentType'],
                      ),
                      _detail('Subcategory', details['subCategory']),
                      _detail('Company', details['company']),
                      _detail(
                        'Description / note',
                        details['description'] ?? details['note'],
                      ),
                      _detail(
                        'Payment source',
                        details['source'] ?? details['paymentSource'],
                      ),
                      _detail('Status', details['status']),
                      _detail(
                        'Settled amount',
                        isGroup
                            ? _formatAmount(
                                _readAmount(details['settledAmountPaise']) /
                                    100,
                              )
                            : _formatAmount(
                                _readAmount(details['settledAmount']),
                              ),
                      ),
                      _detail('Receipt URL', details['receiptUrl']),
                      _detail(
                        'Expense date',
                        _formatDate(details['expenseDate']),
                      ),
                      ..._settlementHistory(details['settlementHistory']),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _detail(String label, dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8EB9E8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(color: _detailValueColor(label), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> _settlementHistory(dynamic value) sync* {
    if (value is! List || value.isEmpty) return;
    yield const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Settlement history at deletion',
          style: TextStyle(
            color: Color(0xFF8CCBFF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    for (var index = 0; index < value.length; index++) {
      final settlement = value[index];
      if (settlement is! Map) continue;
      final amount = _readAmount(settlement['amountPaise']) / 100;
      final settledBy =
          settlement['settledByName'] ?? settlement['settledByEmail'];
      final date = _readDate(settlement['createdAt']);
      yield _detail(
        'Settlement ${index + 1}',
        '${_formatAmount(amount)}${settledBy == null ? '' : ' • $settledBy'}${date == null ? '' : ' • ${DateFormat('dd MMM yyyy, hh:mm a').format(date)}'}',
      );
    }
  }

  Color _detailValueColor(String label) {
    switch (label) {
      case 'Deletion reason':
        return const Color(0xFFFFC857);
      case 'Amount':
      case 'Settled amount':
        return const Color(0xFF72D6B2);
      case 'Status':
        return const Color(0xFF8CCBFF);
      case 'Deleted by':
        return const Color(0xFFC5A8FF);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  static double _readAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String? _formatDate(dynamic value) {
    final date = _readDate(value);
    return date == null ? null : DateFormat('dd MMM yyyy').format(date);
  }

  static String _formatAmount(double amount) {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$formatted';
  }
}
