import 'dart:io';

import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventExpenseGroupsScreen extends StatelessWidget {
  const EventExpenseGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Event Expenses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Please log in to view event expenses.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('eventExpenseGroups')
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load event expenses: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                final groups = snapshot.data!.docs;
                if (groups.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No event expenses yet. Create a group to start tracking shared payments.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final data = group.data();
                    final eventName = data['eventName']?.toString() ?? '';
                    final purpose = data['expensePurpose']?.toString() ?? '';
                    final amount = _paise(data['totalAmountPaise']);
                    final count = data['contributionCount'] is num
                        ? (data['contributionCount'] as num).toInt()
                        : 0;

                    return Card(
                      color: const Color(0xFF1E2638),
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF143048),
                          child: Icon(
                            Icons.groups_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '$purpose • $count ${count == 1 ? 'payment' : 'payments'}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatAmount(amount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => EventExpenseGroupDetailsScreen(
                              groupId: group.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createGroup(context),
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New event group',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Future<void> _createGroup(BuildContext context) async {
    final draft = await showDialog<_EventGroupDraft>(
      context: context,
      builder: (_) => const _EventGroupDialog(),
    );
    if (draft == null || !context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (user == null || email == null || email.isEmpty) {
      _showMessage(context, 'Please log in before creating an event group.');
      return;
    }

    try {
      final name = await _memberName(user, email);
      await FirebaseFirestore.instance.collection('eventExpenseGroups').add({
        'eventName': draft.eventName,
        'expensePurpose': draft.expensePurpose,
        'createdByUid': user.uid,
        'createdByEmail': email,
        'createdByName': name,
        'totalAmountPaise': 0,
        'settledAmountPaise': 0,
        'contributionCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Could not create the event group: $error');
      }
    }
  }
}

class EventExpenseGroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const EventExpenseGroupDetailsScreen({super.key, required this.groupId});

  @override
  State<EventExpenseGroupDetailsScreen> createState() =>
      _EventExpenseGroupDetailsScreenState();
}

class _EventExpenseGroupDetailsScreenState
    extends State<EventExpenseGroupDetailsScreen> {
  CollectionReference<Map<String, dynamic>> get _contributions =>
      FirebaseFirestore.instance
          .collection('eventExpenseGroups')
          .doc(widget.groupId)
          .collection('contributions');

  Future<void> _editContribution(
    String groupName, {
    String? contributionId,
    Map<String, dynamic>? existing,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (user == null || email == null || email.isEmpty) {
      _showMessage(context, 'Please log in before adding a payment.');
      return;
    }

    final draft = await showDialog<_ContributionDraft>(
      context: context,
      builder: (_) =>
          _ContributionDialog(existing: existing, groupName: groupName),
    );
    if (draft == null || !mounted) return;

    try {
      final memberName = contributionId == null
          ? await _memberName(user, email)
          : '';
      final groupReference = FirebaseFirestore.instance
          .collection('eventExpenseGroups')
          .doc(widget.groupId);
      final contributionReference = contributionId == null
          ? _contributions.doc()
          : _contributions.doc(contributionId);
      final isAdministrator =
          email.startsWith('superadmin_') || email.startsWith('instructor_');
      var receiptUrl = existing?['receiptUrl']?.toString() ?? '';
      if (draft.receiptLocalPath != null) {
        final cloudinary = CloudinaryDataSource();
        try {
          receiptUrl = await cloudinary.uploadReceipt(
            filePath: draft.receiptLocalPath!,
            expenseId:
                'event_${widget.groupId}_${contributionReference.id}_${DateTime.now().microsecondsSinceEpoch}',
          );
        } finally {
          cloudinary.dispose();
        }
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final groupSnapshot = await transaction.get(groupReference);
        if (!groupSnapshot.exists) {
          throw Exception('This event group no longer exists.');
        }

        var amountDifference = draft.amountPaise;
        if (contributionId == null) {
          transaction.set(contributionReference, {
            'amountPaise': draft.amountPaise,
            'settledAmountPaise': 0,
            'paidTo': draft.paidTo,
            'paymentType': draft.paymentType,
            'paymentSource': draft.paymentSource,
            'note': draft.note,
            'receiptUrl': receiptUrl,
            'paidAt': Timestamp.fromDate(draft.paidAt),
            'createdByUid': user.uid,
            'createdByEmail': email,
            'createdByName': memberName,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(groupReference, {
            'totalAmountPaise': FieldValue.increment(amountDifference),
            'contributionCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return;
        }

        final contributionSnapshot = await transaction.get(
          contributionReference,
        );
        if (!contributionSnapshot.exists) {
          throw Exception('This payment no longer exists.');
        }
        final oldContribution = contributionSnapshot.data()!;
        final ownerUid = oldContribution['createdByUid']?.toString();
        if (!isAdministrator && ownerUid != user.uid) {
          throw Exception('You can only edit payments you added.');
        }
        amountDifference =
            draft.amountPaise - _paise(oldContribution['amountPaise']);
        final newContributionSettledPaise = _paise(
          oldContribution['settledAmountPaise'],
        );
        if (draft.amountPaise < newContributionSettledPaise) {
          throw Exception(
            'The payment cannot be reduced below its settled amount.',
          );
        }

        transaction.update(contributionReference, {
          'amountPaise': draft.amountPaise,
          'paidTo': draft.paidTo,
          'paymentType': draft.paymentType,
          'paymentSource': draft.paymentSource,
          'note': draft.note,
          'receiptUrl': receiptUrl,
          'paidAt': Timestamp.fromDate(draft.paidAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(groupReference, {
          'totalAmountPaise': FieldValue.increment(amountDifference),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Could not save this payment: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupReference = FirebaseFirestore.instance
        .collection('eventExpenseGroups')
        .doc(widget.groupId);
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase() ?? '';
    final canEditAll =
        email.startsWith('superadmin_') || email.startsWith('instructor_');

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Payment history',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: groupReference.snapshots(),
        builder: (context, groupSnapshot) {
          if (groupSnapshot.hasError) {
            return _errorMessage(
              'Could not load this event group: ${groupSnapshot.error}',
            );
          }
          if (!groupSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (!groupSnapshot.data!.exists) {
            return _errorMessage('This event group no longer exists.');
          }

          final group = groupSnapshot.data!.data()!;
          final eventName = group['eventName']?.toString() ?? 'Event';
          final purpose = group['expensePurpose']?.toString() ?? '';
          final totalPaise = _paise(group['totalAmountPaise']);
          final storedGroupSettledPaise = _paise(group['settledAmountPaise']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _contributions.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _errorMessage(
                      'Could not load event payment totals: ${snapshot.error}',
                    );
                  }
                  var settledPaise = storedGroupSettledPaise;
                  if (snapshot.hasData) {
                    final prepaidNotSettledPaise = snapshot.data!.docs
                        .where(
                          (payment) =>
                              payment.data()['paymentSource'] == 'Prepaid',
                        )
                        .fold<int>(0, (total, payment) {
                          final data = payment.data();
                          final amountPaise = _paise(data['amountPaise']);
                          final contributionSettledPaise = _paise(
                            data['settledAmountPaise'],
                          );
                          return total +
                              (amountPaise - contributionSettledPaise).clamp(
                                0,
                                amountPaise,
                              );
                        });
                    settledPaise += prepaidNotSettledPaise;
                  }
                  settledPaise = settledPaise.clamp(0, totalPaise);
                  final remainingPaise = (totalPaise - settledPaise).clamp(
                    0,
                    totalPaise,
                  );

                  return Container(
                    color: const Color(0xFF1E2638),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purpose,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total contributed',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatAmount(totalPaise),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white60),
                            children: [
                              const TextSpan(text: 'Settled '),
                              TextSpan(
                                text: _formatAmount(settledPaise),
                                style: const TextStyle(
                                  color: Color(0xFF00D09C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '  •  Remaining '),
                              TextSpan(
                                text: _formatAmount(remainingPaise),
                                style: const TextStyle(
                                  color: Color(0xFFFF5271),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EventExpenseSettlementHistoryScreen(
                        groupId: widget.groupId,
                        eventName: eventName,
                        purpose: purpose,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('View settlement history'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlueAccent,
                    side: const BorderSide(color: Color(0xFF315477)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Contributions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _contributions
                      .orderBy('paidAt', descending: true)
                      .snapshots(),
                  builder: (context, contributionSnapshot) {
                    if (contributionSnapshot.hasError) {
                      return _errorMessage(
                        'Could not load payment history: ${contributionSnapshot.error}',
                      );
                    }
                    if (!contributionSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    final payments = contributionSnapshot.data!.docs;
                    if (payments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No payments have been added to this group.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    final prepaidNotSettledPaise = payments
                        .where(
                          (payment) =>
                              payment.data()['paymentSource'] == 'Prepaid',
                        )
                        .fold<int>(0, (total, payment) {
                          final data = payment.data();
                          final amountPaise = _paise(data['amountPaise']);
                          final contributionSettledPaise = _paise(
                            data['settledAmountPaise'],
                          );
                          return total +
                              (amountPaise - contributionSettledPaise).clamp(
                                0,
                                amountPaise,
                              );
                        });
                    final groupRemainingPaise =
                        (totalPaise -
                                storedGroupSettledPaise -
                                prepaidNotSettledPaise)
                            .clamp(0, totalPaise);

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: payments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final data = payment.data();
                        final ownerUid = data['createdByUid']?.toString();
                        final canEdit = canEditAll || ownerUid == user?.uid;
                        final payer =
                            data['createdByName']?.toString() ??
                            data['createdByEmail']?.toString() ??
                            'Member';
                        final paidTo = data['paidTo']?.toString() ?? '';
                        final date = _readDate(data['paidAt']);
                        final note = data['note']?.toString() ?? '';
                        final paymentType =
                            data['paymentType']?.toString() ?? 'Contribution';
                        final paymentSource =
                            data['paymentSource']?.toString() == 'Prepaid'
                            ? 'Prepaid'
                            : 'Wallet';
                        final receiptUrl =
                            data['receiptUrl']?.toString().trim() ?? '';
                        final contributionTotalPaise = _paise(
                          data['amountPaise'],
                        );
                        final isPrepaid = paymentSource == 'Prepaid';
                        final contributionSettledPaise = isPrepaid
                            ? contributionTotalPaise
                            : _paise(data['settledAmountPaise']);
                        final contributionRemainingPaise =
                            (contributionTotalPaise - contributionSettledPaise)
                                .clamp(0, contributionTotalPaise);
                        final settleablePaise =
                            contributionRemainingPaise < groupRemainingPaise
                            ? contributionRemainingPaise
                            : groupRemainingPaise;
                        final isSettled = contributionRemainingPaise == 0;
                        final isPartiallySettled =
                            contributionSettledPaise > 0 && !isSettled;
                        final statusColor = isSettled
                            ? const Color(0xFF00D09C)
                            : Colors.redAccent;

                        return Card(
                          color: const Color(0xFF1E2638),
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF0D3838),
                              child: Icon(
                                Icons.payments_outlined,
                                color: Color(0xFF00D09C),
                              ),
                            ),
                            title: Text(
                              '$paymentType • ${_formatAmount(_paise(data['amountPaise']))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    [
                                      'Paid by $payer • Given to $paidTo',
                                      paymentSource == 'Prepaid'
                                          ? 'Prepaid'
                                          : 'Paid from Wallet',
                                      if (date != null)
                                        MaterialLocalizations.of(
                                          context,
                                        ).formatMediumDate(date),
                                      if (note.isNotEmpty) note,
                                    ].join('\n'),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (contributionSettledPaise > 0)
                                    Text(
                                      'Settled: ${_formatAmount(contributionSettledPaise)}',
                                      style: const TextStyle(
                                        color: Color(0xFF00D09C),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (contributionRemainingPaise > 0)
                                    Text(
                                      'Remaining: ${_formatAmount(contributionRemainingPaise)}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF5271),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (receiptUrl.isNotEmpty || canEditAll) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 0,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (receiptUrl.isNotEmpty)
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showReceipt(receiptUrl),
                                            icon: const Icon(
                                              Icons.receipt_long_outlined,
                                              size: 16,
                                            ),
                                            label: const Text('View receipt'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Colors.lightBlueAccent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                        if (canEditAll && !isPrepaid)
                                          InkWell(
                                            onTap:
                                                !isSettled &&
                                                    settleablePaise > 0
                                                ? () => _openStandardSettlement(
                                                    groupId: widget.groupId,
                                                    contributionId: payment.id,
                                                    remainingAmount:
                                                        settleablePaise / 100,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(
                                                  alpha: 0.12,
                                                ),
                                                border: Border.all(
                                                  color: statusColor.withValues(
                                                    alpha: 0.55,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isSettled
                                                    ? 'Settled'
                                                    : isPartiallySettled
                                                    ? 'Partially Settled'
                                                    : 'Not Settled',
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            isThreeLine: true,
                            trailing: canEdit
                                ? IconButton(
                                    tooltip: 'Edit payment',
                                    onPressed: () => _editContribution(
                                      eventName,
                                      contributionId: payment.id,
                                      existing: data,
                                    ),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white70,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addPayment,
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add payment',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Future<void> _openStandardSettlement({
    required String groupId,
    required String contributionId,
    required double remainingAmount,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme().appBarBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => BottomsheetSettle().getBottomSheetOpen({
        'id': 'group_${groupId}_$contributionId',
        'amount': remainingAmount,
        'eventExpenseGroup': true,
        'groupId': groupId,
        'contributionId': contributionId,
        'paymentSource': 'Wallet',
      }),
    );
  }

  Future<void> _showReceipt(String receiptUrl) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                receiptUrl,
                errorBuilder: (_, _, _) => const Center(
                  child: Text(
                    'Unable to load receipt.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPayment() async {
    try {
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('eventExpenseGroups')
          .doc(widget.groupId)
          .get();
      if (!groupSnapshot.exists) {
        throw Exception('This event group no longer exists.');
      }
      final group = groupSnapshot.data()!;
      await _editContribution(group['eventName']?.toString() ?? 'Event');
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Could not open this event group: $error');
      }
    }
  }

  Widget _errorMessage(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    ),
  );
}

class EventExpenseSettlementHistoryScreen extends StatelessWidget {
  final String groupId;
  final String eventName;
  final String purpose;

  const EventExpenseSettlementHistoryScreen({
    super.key,
    required this.groupId,
    required this.eventName,
    required this.purpose,
  });

  @override
  Widget build(BuildContext context) {
    final settlements = FirebaseFirestore.instance
        .collection('eventExpenseGroups')
        .doc(groupId)
        .collection('settlements')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Settlement history',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2638),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C374B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (purpose.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(purpose, style: const TextStyle(color: Colors.white60)),
                ],
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: settlements,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load settlements: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                final entries = snapshot.data!.docs;
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No settlements recorded yet.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final settlement = entries[index].data();
                    final date = _readDate(settlement['createdAt']);
                    final amount = _formatAmount(
                      _paise(settlement['amountPaise']),
                    );
                    final contributionName =
                        settlement['contributionName']?.toString().trim() ?? '';
                    final paidTo =
                        settlement['paidTo']?.toString().trim() ?? '';
                    final settledBy =
                        settlement['settledByName']
                                ?.toString()
                                .trim()
                                .isNotEmpty ==
                            true
                        ? settlement['settledByName'].toString().trim()
                        : settlement['settledByEmail']?.toString() ?? 'Admin';
                    final source =
                        settlement['settlementSource']?.toString() ?? 'Manual';

                    return Card(
                      color: const Color(0xFF1E2638),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF2C374B)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 19,
                                  backgroundColor: Color(0xFF0D3838),
                                  child: Icon(
                                    Icons.verified_outlined,
                                    size: 20,
                                    color: Color(0xFF00D09C),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    amount,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF143048,
                                    ).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    source,
                                    style: const TextStyle(
                                      color: Color(0xFF8CCBFF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (contributionName.isNotEmpty)
                              _settlementDetail('Payment by', contributionName),
                            if (paidTo.isNotEmpty)
                              _settlementDetail('Paid to', paidTo),
                            _settlementDetail('Settled by', settledBy),
                            _settlementDetail(
                              'Date',
                              date == null
                                  ? 'Date unavailable'
                                  : '${MaterialLocalizations.of(context).formatFullDate(date)} • ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _settlementDetail(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

class _EventGroupDraft {
  final String eventName;
  final String expensePurpose;

  const _EventGroupDraft(this.eventName, this.expensePurpose);
}

class _EventGroupDialog extends StatefulWidget {
  const _EventGroupDialog();

  @override
  State<_EventGroupDialog> createState() => _EventGroupDialogState();
}

class _EventGroupDialogState extends State<_EventGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _eventController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2638),
      title: const Text(
        'Create event group',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(
              controller: _eventController,
              label: 'Event name',
              hint: 'Ganpati Festival',
            ),
            const SizedBox(height: 12),
            _dialogField(
              controller: _purposeController,
              label: 'Expense group',
              hint: 'Food',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _EventGroupDraft(
                _eventController.text.trim(),
                _purposeController.text.trim(),
              ),
            );
          },
          child: const Text('Create group'),
        ),
      ],
    );
  }
}

class _ContributionDraft {
  final int amountPaise;
  final String paidTo;
  final String paymentType;
  final String paymentSource;
  final String note;
  final DateTime paidAt;
  final String? receiptLocalPath;

  const _ContributionDraft({
    required this.amountPaise,
    required this.paidTo,
    required this.paymentType,
    required this.paymentSource,
    required this.note,
    required this.paidAt,
    required this.receiptLocalPath,
  });
}

class _ContributionDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final String groupName;

  const _ContributionDialog({required this.existing, required this.groupName});

  @override
  State<_ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<_ContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _paidToController;
  late final TextEditingController _noteController;
  XFile? _receiptFile;
  String _existingReceiptUrl = '';
  late DateTime _paidAt;
  late String _paymentType;
  late String _paymentSource;

  static const _paymentTypes = ['Advance', 'Final payment', 'Other'];
  static const _paymentSources = ['Wallet', 'Prepaid'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController = TextEditingController(
      text: existing == null
          ? ''
          : (_paise(existing['amountPaise']) / 100).toStringAsFixed(
              _paise(existing['amountPaise']) % 100 == 0 ? 0 : 2,
            ),
    );
    _paidToController = TextEditingController(
      text: existing?['paidTo']?.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: existing?['note']?.toString() ?? '',
    );
    _existingReceiptUrl = existing?['receiptUrl']?.toString().trim() ?? '';
    _paidAt = _readDate(existing?['paidAt']) ?? DateTime.now();
    final savedType = existing?['paymentType']?.toString();
    _paymentType = _paymentTypes.contains(savedType)
        ? savedType!
        : _paymentTypes.first;
    final savedSource = existing?['paymentSource']?.toString();
    _paymentSource = savedSource == 'Prepaid' ? 'Prepaid' : 'Wallet';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paidToController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _paidAt.isAfter(today) ? today : _paidAt,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (date != null && mounted) setState(() => _paidAt = date);
  }

  Future<void> _pickReceipt() async {
    try {
      final receipt = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (receipt == null) return;
      final fileSize = await receipt.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (mounted) {
          _showMessage(context, 'Receipt image must be 10 MB or smaller.');
        }
        return;
      }
      if (mounted) setState(() => _receiptFile = receipt);
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not select receipt: $error');
    }
  }

  Future<void> _previewReceipt() {
    final receiptFile = _receiptFile;
    final image = receiptFile != null
        ? Image.file(
            File(receiptFile.path),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Center(
              child: Text(
                'Unable to load receipt.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : Image.network(
            _existingReceiptUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Center(
              child: Text(
                'Unable to load receipt.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: MediaQuery.of(dialogContext).size.width,
          height: MediaQuery.of(dialogContext).size.height * 0.8,
          child: Stack(
            children: [
              InteractiveViewer(child: image),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2638),
      title: Text(
        widget.existing == null ? 'Add payment' : 'Edit payment',
        style: const TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.groupName,
                  style: const TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 12),
              _dialogField(
                controller: _amountController,
                label: 'Amount (₹)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter an amount greater than zero.';
                  }
                  final paise = (amount * 100).round();
                  if ((amount * 100 - paise).abs() > 0.000001) {
                    return 'Enter no more than two decimal places.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _dialogField(
                controller: _paidToController,
                label: 'Paid to',
                hint: 'Person who received the money',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentType,
                dropdownColor: const Color(0xFF1E2638),
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Payment type'),
                items: _paymentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentType = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentSource,
                dropdownColor: const Color(0xFF1E2638),
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Payment source'),
                items: _paymentSources
                    .map(
                      (source) =>
                          DropdownMenuItem(value: source, child: Text(source)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _paymentSource = value);
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: _fieldDecoration('Date paid'),
                  child: Text(
                    MaterialLocalizations.of(context).formatMediumDate(_paidAt),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _dialogField(
                controller: _noteController,
                label: 'Note (optional)',
                hint: 'For example, remaining amount',
                required: false,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Receipt${widget.existing == null ? '' : ' (optional)'}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickReceipt,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _receiptFile == null ? 'Choose image' : 'Change image',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _receiptFile?.name ??
                          (_existingReceiptUrl.isNotEmpty
                              ? 'Receipt attached'
                              : 'JPG, PNG, WEBP (max 10 MB)'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (_receiptFile != null || _existingReceiptUrl.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _previewReceipt,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Preview receipt'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            if (_receiptFile == null && _existingReceiptUrl.isEmpty) {
              _showMessage(context, 'Please attach a receipt image.');
              return;
            }
            Navigator.pop(
              context,
              _ContributionDraft(
                amountPaise: (double.parse(_amountController.text.trim()) * 100)
                    .round(),
                paidTo: _paidToController.text.trim(),
                paymentType: _paymentType,
                paymentSource: _paymentSource,
                note: _noteController.text.trim(),
                paidAt: _paidAt,
                receiptLocalPath: _receiptFile?.path,
              ),
            );
          },
          child: const Text('Save payment'),
        ),
      ],
    );
  }
}

Widget _dialogField({
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType? keyboardType,
  bool required = true,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    cursorColor: Colors.blue,
    style: const TextStyle(color: Colors.white),
    decoration: _fieldDecoration(label, hint: hint),
    validator:
        validator ??
        (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'This field is required.';
          }
          return null;
        },
  );
}

InputDecoration _fieldDecoration(String label, {String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    );

Future<String> _memberName(User user, String email) async {
  final profileEmail = _profileEmail(email);
  final profile = await FirebaseFirestore.instance
      .collection('UserData')
      .doc(profileEmail)
      .get();
  final name = profile.data()?['Name']?.toString().trim() ?? '';
  if (name.isNotEmpty) return name;
  final displayName = user.displayName?.trim() ?? '';
  return displayName.isNotEmpty ? displayName : profileEmail;
}

String _profileEmail(String email) {
  for (final role in ['teamlead', 'mentor', 'instructor', 'superadmin']) {
    final prefix = '${role}_';
    if (email.startsWith(prefix)) return email.substring(prefix.length);
  }
  return email;
}

int _paise(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String _formatAmount(int paise) {
  final rupees = paise ~/ 100;
  final remainder = paise.abs() % 100;
  if (remainder == 0) return '₹$rupees';
  return '₹$rupees.${remainder.toString().padLeft(2, '0')}';
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
