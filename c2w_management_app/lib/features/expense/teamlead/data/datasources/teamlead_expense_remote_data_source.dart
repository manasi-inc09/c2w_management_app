import 'dart:async';
import 'dart:developer';

import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/wallet_financial_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _CompanyExpenseAccumulator {
  double totalExpenses = 0;
  double walletFundedExpenses = 0;
}

class ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final CloudinaryDataSource _cloudinaryDataSource;

  ExpenseRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required CloudinaryDataSource cloudinaryDataSource,
  }) : _firestore = firestore,
       _auth = auth,
       _cloudinaryDataSource = cloudinaryDataSource;

  Future<String> createExpense(Expense expense) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in before submitting an expense.');
    }

    final authEmail = user.email;
    if (authEmail == null || authEmail.isEmpty) {
      throw Exception('Your account does not have an email address.');
    }
    final email = _profileEmail(authEmail);
    log("+++++++++++++++++++++$email");

    final userDocument = await _firestore
        .collection('UserData')
        .doc(email)
        .get();
    log("------${userDocument.exists}");
    if (!userDocument.exists) {
      throw Exception('User profile was not found.');
    }

    final userData = userDocument.data()!;

    if (userData['isActive'] == false) {
      throw Exception('Your account is inactive.');
    }

    final claimantName =
        (userData['Name'] as String?) ?? user.displayName ?? 'Unknown User';

    final claimantRole = userData['Role'] as String?;

    if (claimantRole == null || claimantRole.isEmpty) {
      throw Exception('User role is missing from the profile.');
    }

    //final teamId = userData['teamId'];

    // Generate a unique Firestore document ID.
    final expenseReference = _firestore.collection('expenses').doc();
    final expenseId = expenseReference.id;

    String? receiptUrl;

    // Upload receipt only when a local image path is provided.
    final receiptLocalPath = expense.receiptLocalPath;

    if (receiptLocalPath != null && receiptLocalPath.isNotEmpty) {
      receiptUrl = await _cloudinaryDataSource.uploadReceipt(
        filePath: receiptLocalPath,
        expenseId: expenseId,
      );
    }

    final expenseData = <String, dynamic>{
      'claimantId': user.uid,
      'claimantName': claimantName,
      'claimantRole': claimantRole,
      'email': email,

      'expenseDate': Timestamp.fromDate(expense.expenseDate),
      'amount': expense.amount,
      'currency': 'INR',
      'source': expense.source,
      'description': expense.description,
      'category': expense.category,
      'company': expense.company,
      'subCategory': expense.subCategory,

      'receiptUrl': receiptUrl,
      'status': 'Pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await expenseReference.set(expenseData);
    return expenseId;
  }

  Future<void> updateExpense({
    required String expenseId,
    required Expense expense,
    required String? existingReceiptUrl,
  }) async {
    if (expenseId.trim().isEmpty) {
      throw Exception('Transaction ID is required to update an expense.');
    }

    final user = _auth.currentUser;
    final authEmail = user?.email?.toLowerCase();
    if (authEmail == null || authEmail.isEmpty) {
      throw Exception('Please log in before updating a transaction.');
    }

    final expenseReference = _firestore.collection('expenses').doc(expenseId);
    final expenseSnapshot = await expenseReference.get();
    if (!expenseSnapshot.exists) {
      throw Exception('This transaction no longer exists.');
    }

    final isAdminOrInstructor =
        authEmail.startsWith('superadmin_') ||
        authEmail.startsWith('instructor_');
    final isOwnerRole =
        authEmail.startsWith('mentor_') || authEmail.startsWith('teamlead_');
    final ownerEmail = expenseSnapshot
        .data()?['email']
        ?.toString()
        .toLowerCase();
    if (!isAdminOrInstructor &&
        !(isOwnerRole && _profileEmail(authEmail) == ownerEmail)) {
      throw Exception('You are not allowed to update this transaction.');
    }

    var receiptUrl = existingReceiptUrl;
    final receiptLocalPath = expense.receiptLocalPath;
    if (receiptLocalPath != null && receiptLocalPath.isNotEmpty) {
      receiptUrl = await _cloudinaryDataSource.uploadReceipt(
        filePath: receiptLocalPath,
        expenseId: '${expenseId}_${DateTime.now().microsecondsSinceEpoch}',
      );
    }

    await expenseReference.update({
      'expenseDate': Timestamp.fromDate(expense.expenseDate),
      'amount': expense.amount,
      'source': expense.source,
      'description': expense.description,
      'category': expense.category,
      'company': expense.company,
      'subCategory': expense.subCategory,
      'receiptUrl': receiptUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email) {
    return _firestore
        .collection('expenses')
        .where('email', isEqualTo: email)
        .snapshots()
        .asyncMap(
          (snapshot) => _addProfileImages(
            snapshot.docs
                .map(
                  (document) => <String, dynamic>{
                    ...document.data(),
                    'id': document.id,
                  },
                )
                .toList(),
          ),
        );
  }

  Stream<List<Map<String, dynamic>>> watchAllExpenses() {
    return _firestore
        .collection('expenses')
        .snapshots()
        .asyncMap(
          (snapshot) => _addProfileImages(
            snapshot.docs
                .map(
                  (document) => <String, dynamic>{
                    ...document.data(),
                    'id': document.id,
                  },
                )
                .toList(),
          ),
        );
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    return _addProfileImages(
      snapshot.docs
          .map(
            (document) => <String, dynamic>{
              ...document.data(),
              'id': document.id,
            },
          )
          .toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchExpenseHistoryByEmail(String email) {
    return _watchExpenseHistory(
      expensesStream: _firestore
          .collection('expenses')
          .where('email', isEqualTo: email)
          .snapshots(),
      memberEmail: email,
    );
  }

  Stream<List<Map<String, dynamic>>> watchAllExpenseHistory() {
    return _watchExpenseHistory(
      expensesStream: _firestore.collection('expenses').snapshots(),
    );
  }

  Future<List<Map<String, dynamic>>> getAllExpenseHistory() async {
    final results = await Future.wait([
      _firestore.collection('expenses').get(),
      _firestore.collection('eventExpenseGroups').get(),
    ]);
    final expenses = results[0];
    final groups = results[1];
    return _composeExpenseHistory(
      expenses.docs
          .map(
            (document) => <String, dynamic>{
              ...document.data(),
              'id': document.id,
            },
          )
          .toList(),
      groups.docs.map(_eventGroupAsExpense).toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> _watchExpenseHistory({
    required Stream<QuerySnapshot<Map<String, dynamic>>> expensesStream,
    String? memberEmail,
  }) {
    late final StreamController<List<Map<String, dynamic>>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    expensesSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? groupsSubscription;
    List<Map<String, dynamic>>? expenses;
    List<Map<String, dynamic>>? groups;
    var composing = false;
    var publishPending = false;

    Future<void> publish() async {
      if (expenses == null || groups == null) return;
      if (composing) {
        publishPending = true;
        return;
      }
      composing = true;
      try {
        final history = await _composeExpenseHistory(
          expenses!,
          groups!,
          memberEmail: memberEmail,
        );
        if (!controller.isClosed) controller.add(history);
      } catch (error, stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      } finally {
        composing = false;
        if (publishPending) {
          publishPending = false;
          unawaited(publish());
        }
      }
    }

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        expensesSubscription = expensesStream.listen(
          (snapshot) {
            expenses = snapshot.docs
                .map(
                  (document) => <String, dynamic>{
                    ...document.data(),
                    'id': document.id,
                  },
                )
                .toList();
            unawaited(publish());
          },
          onError: (Object error, StackTrace stackTrace) =>
              controller.addError(error, stackTrace),
        );
        groupsSubscription = _firestore
            .collection('eventExpenseGroups')
            .snapshots()
            .listen(
              (snapshot) {
                groups = snapshot.docs.map(_eventGroupAsExpense).toList();
                unawaited(publish());
              },
              onError: (Object error, StackTrace stackTrace) =>
                  controller.addError(error, stackTrace),
            );
      },
      onCancel: () async {
        await expensesSubscription?.cancel();
        await groupsSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _composeExpenseHistory(
    List<Map<String, dynamic>> expenses,
    List<Map<String, dynamic>> groups, {
    String? memberEmail,
  }) async {
    final expenseHistory = await _addProfileImages(expenses);
    final List<Map<String, dynamic>> eventHistory;
    if (memberEmail == null) {
      final contributions = await _getGroupContributions(groups);
      final sourceTotalsByGroup = <String, Map<String, double>>{};
      for (final contribution in contributions) {
        final groupId = contribution['groupId']?.toString();
        if (groupId == null) continue;
        final totals = sourceTotalsByGroup.putIfAbsent(
          groupId,
          () => {
            'walletAmount': 0,
            'prepaidAmount': 0,
            'prepaidNotSettledAmount': 0,
          },
        );
        final source = contribution['paymentSource']?.toString();
        final key = source == 'Prepaid' ? 'prepaidAmount' : 'walletAmount';
        final amount = contribution['amount'];
        if (amount is num) totals[key] = totals[key]! + amount.toDouble();
        if (source == 'Prepaid' && amount is num) {
          final storedSettledPaise = _toPaise(
            contribution['settledAmountPaise'],
          );
          final amountPaise = (amount.toDouble() * 100).round();
          totals['prepaidNotSettledAmount'] =
              totals['prepaidNotSettledAmount']! +
              (amountPaise - storedSettledPaise).clamp(0, amountPaise) / 100;
        }
      }

      eventHistory = groups
          .where((group) => _toPaise(group['totalAmountPaise']) > 0)
          .map((group) {
            final groupId = (group['groupId'] ?? group['id']).toString();
            final sourceTotals = sourceTotalsByGroup[groupId] ?? const {};
            final totalPaise = _toPaise(group['totalAmountPaise']);
            final settledPaise =
                (_toPaise(group['settledAmountPaise']) +
                          ((sourceTotals['prepaidNotSettledAmount'] ?? 0) * 100)
                              .round())
                    .clamp(0, totalPaise);
            final remainingPaise = (totalPaise - settledPaise).clamp(
              0,
              totalPaise,
            );
            return {
              ...group,
              ...sourceTotals,
              'settledAmount': settledPaise / 100,
              'remainingAmount': remainingPaise / 100,
              'status': remainingPaise == 0
                  ? 'Settled'
                  : settledPaise > 0
                  ? 'Partially Settled'
                  : 'Pending',
            };
          })
          .toList();
    } else {
      eventHistory = await _getGroupContributions(
        groups,
        memberEmail: memberEmail,
      );
    }
    final history = [...expenseHistory, ...eventHistory];
    history.sort((first, second) {
      final firstDate = _historyDate(first);
      final secondDate = _historyDate(second);
      return (secondDate?.millisecondsSinceEpoch ?? 0).compareTo(
        firstDate?.millisecondsSinceEpoch ?? 0,
      );
    });
    return history;
  }

  Future<List<Map<String, dynamic>>> _getGroupContributions(
    List<Map<String, dynamic>> groups, {
    String? memberEmail,
  }) async {
    if (groups.isEmpty) return const [];
    final groupById = {
      for (final group in groups)
        (group['groupId'] ?? group['id']).toString(): group,
    };
    final contributions = await _firestore
        .collectionGroup('contributions')
        .get();
    final normalizedMemberEmail = memberEmail == null
        ? null
        : _profileEmail(memberEmail.toLowerCase());
    final history = <Map<String, dynamic>>[];

    for (final document in contributions.docs) {
      final groupId = document.reference.parent.parent?.id;
      final group = groupId == null ? null : groupById[groupId];
      if (group == null) continue;

      final contribution = document.data();
      final contributorEmail =
          contribution['createdByEmail']?.toString().toLowerCase() ?? '';
      final contributorProfileEmail = _profileEmail(contributorEmail);
      if (normalizedMemberEmail != null &&
          contributorProfileEmail != normalizedMemberEmail) {
        continue;
      }

      final amountPaise = _toPaise(contribution['amountPaise']);
      final isPrepaid = contribution['paymentSource']?.toString() == 'Prepaid';
      final contributionSettledPaise = isPrepaid
          ? amountPaise
          : _toPaise(contribution['settledAmountPaise']);
      final contributionRemainingPaise =
          (amountPaise - contributionSettledPaise).clamp(0, amountPaise);
      final fullySettled = amountPaise > 0 && contributionRemainingPaise == 0;
      final eventName = group['eventName']?.toString() ?? 'Event';
      final purpose = group['expensePurpose']?.toString() ?? '';

      history.add({
        ...contribution,
        'id': 'group_${groupId}_${document.id}',
        'groupId': groupId,
        'eventExpenseGroup': true,
        'eventExpenseGroupContribution': true,
        'groupName': eventName,
        'claimantName': contribution['createdByName']?.toString() ?? 'Member',
        'email': contributorProfileEmail,
        'contributorAuthEmail': contributorEmail,
        'expenseDate': contribution['paidAt'],
        'amount': amountPaise / 100,
        'settledAmount': contributionSettledPaise / 100,
        'remainingAmount': contributionRemainingPaise / 100,
        'status': fullySettled
            ? 'Settled'
            : contributionSettledPaise > 0
            ? 'Partially Settled'
            : 'Pending',
        'category': purpose.isEmpty ? 'Group Expense' : purpose,
        'description': purpose.isEmpty
            ? contribution['paymentType']?.toString() ?? 'Group expense'
            : purpose,
        'subCategory': contribution['paymentType']?.toString() ?? '',
        'paymentSource': contribution['paymentSource']?.toString() == 'Prepaid'
            ? 'Prepaid'
            : 'Wallet',
        'source': 'Group Expense',
      });
    }

    return history;
  }

  Map<String, dynamic> _eventGroupAsExpense(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final group = document.data();
    final totalPaise = _toPaise(group['totalAmountPaise']);
    final settledPaise = _toPaise(group['settledAmountPaise']);
    final remainingPaise = (totalPaise - settledPaise).clamp(0, totalPaise);
    final status = totalPaise > 0 && remainingPaise == 0
        ? 'Settled'
        : settledPaise > 0
        ? 'Partially Settled'
        : 'Pending';
    final eventName = group['eventName']?.toString() ?? 'Event';
    final purpose = group['expensePurpose']?.toString() ?? '';

    return {
      ...group,
      'id': 'group_${document.id}',
      'groupId': document.id,
      'eventExpenseGroup': true,
      'groupName': eventName,
      'claimantName': group['createdByName']?.toString() ?? 'Event group',
      'email': group['createdByEmail']?.toString() ?? '',
      'expenseDate': group['updatedAt'] ?? group['createdAt'],
      'amount': totalPaise / 100,
      'settledAmount': settledPaise / 100,
      'remainingAmount': remainingPaise / 100,
      'status': status,
      'category': 'Group Expense',
      'description': purpose,
      'subCategory': eventName,
      'source': 'Group Expense',
    };
  }

  DateTime? _historyDate(Map<String, dynamic> record) {
    final value = record['expenseDate'] ?? record['submittedAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int _toPaise(dynamic value) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _settleEventExpenseContribution({
    required String groupId,
    required String contributionId,
    required double amount,
    required bool fromWallet,
  }) async {
    final user = _requireWalletSettler();
    if (groupId.trim().isEmpty || contributionId.trim().isEmpty) {
      throw Exception('This group payment could not be identified.');
    }
    if (!amount.isFinite || amount <= 0) {
      throw Exception('Enter a settlement amount greater than zero.');
    }
    final amountPaise = (amount * 100).round();
    if ((amount * 100 - amountPaise).abs() > 0.000001) {
      throw Exception('Enter no more than two decimal places.');
    }

    final email = user.email!.trim().toLowerCase();
    final profileEmail = _profileEmail(email);
    final userSnapshot = await _firestore
        .collection('UserData')
        .doc(profileEmail)
        .get();
    final settledByName =
        userSnapshot.data()?['Name']?.toString().trim().isNotEmpty == true
        ? userSnapshot.data()!['Name'].toString().trim()
        : profileEmail;

    final groupReference = _firestore
        .collection('eventExpenseGroups')
        .doc(groupId);
    final contributionReference = groupReference
        .collection('contributions')
        .doc(contributionId);
    final settlementReference = groupReference.collection('settlements').doc();
    final walletReference = _firestore
        .collection('wallets')
        .doc('organization');
    final ledgerReference = walletReference.collection('ledger').doc();
    await _firestore.runTransaction((transaction) async {
      final groupSnapshot = await transaction.get(groupReference);
      final contributionSnapshot = await transaction.get(contributionReference);
      final walletSnapshot = fromWallet
          ? await transaction.get(walletReference)
          : null;
      if (!groupSnapshot.exists) {
        throw Exception('This event group no longer exists.');
      }
      if (!contributionSnapshot.exists) {
        throw Exception('This group payment no longer exists.');
      }
      final group = groupSnapshot.data()!;
      final contribution = contributionSnapshot.data()!;
      if (contribution['paymentSource']?.toString() == 'Prepaid') {
        throw Exception('Prepaid group payments do not need settlement.');
      }
      final totalPaise = _toPaise(group['totalAmountPaise']);
      final settledPaise = _toPaise(group['settledAmountPaise']);
      final contributionTotalPaise = _toPaise(contribution['amountPaise']);
      final contributionSettledPaise = _toPaise(
        contribution['settledAmountPaise'],
      );
      final remainingPaise = contributionTotalPaise - contributionSettledPaise;
      final groupRemainingPaise = totalPaise - settledPaise;
      if (remainingPaise <= 0 || groupRemainingPaise <= 0) {
        throw Exception('This group payment is already settled.');
      }
      if (amountPaise > remainingPaise || amountPaise > groupRemainingPaise) {
        throw Exception('Settlement amount cannot exceed the remaining total.');
      }

      double? nextBalance;
      if (fromWallet) {
        final currentBalance = walletSnapshot?.data()?['balance'];
        final balance = currentBalance is num ? currentBalance.toDouble() : 0;
        if (amount > balance) {
          throw Exception('The wallet does not have enough balance.');
        }
        nextBalance = balance - amount;
      }

      final updatedContributionSettledPaise =
          contributionSettledPaise + amountPaise;
      final updatedGroupSettledPaise = settledPaise + amountPaise;
      transaction.update(contributionReference, {
        'settledAmountPaise': FieldValue.increment(amountPaise),
        'status': updatedContributionSettledPaise == contributionTotalPaise
            ? 'Settled'
            : 'Partially Settled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(groupReference, {
        'settledAmountPaise': FieldValue.increment(amountPaise),
        'status': updatedGroupSettledPaise >= totalPaise
            ? 'Settled'
            : 'Partially Settled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(settlementReference, {
        'contributionId': contributionId,
        'contributionName':
            contribution['createdByName']?.toString() ??
            contribution['createdByEmail']?.toString() ??
            'Member',
        'paidTo': contribution['paidTo']?.toString() ?? '',
        'amountPaise': amountPaise,
        'settlementSource': fromWallet ? 'Wallet' : 'Manual',
        'settledByUid': user.uid,
        'settledByEmail': email,
        'settledByName': settledByName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (nextBalance != null) {
        transaction.set(walletReference, {
          'balance': nextBalance,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': profileEmail,
        }, SetOptions(merge: true));
        transaction.set(ledgerReference, {
          'type': 'settlement',
          'expenseId': 'group_${groupId}_$contributionId',
          'groupId': groupId,
          'contributionId': contributionId,
          'amount': amount,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': profileEmail,
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _addProfileImages(
    List<Map<String, dynamic>> expenses,
  ) async {
    if (expenses.isEmpty) return expenses;

    final emails = expenses
        .map((expense) => expense['email']?.toString().trim())
        .whereType<String>()
        .where((email) => email.isNotEmpty)
        .toSet();
    final userDocuments = await Future.wait(
      emails.map((email) => _firestore.collection('UserData').doc(email).get()),
    );
    final profileImages = <String, String>{};
    for (final document in userDocuments) {
      if (!document.exists) continue;
      profileImages[document.id.toLowerCase()] =
          document.data()?['profileImage']?.toString() ?? '';
    }

    return expenses.map((expense) {
      final email = expense['email']?.toString().toLowerCase();
      final normalizedExpense = <String, dynamic>{
        ...expense,
        'profileImage': profileImages[email] ?? '',
      };
      if (expense['source']?.toString().toLowerCase() == 'prepaid') {
        final amount = expense['amount'];
        final total = amount is num
            ? amount.toDouble()
            : double.tryParse(amount?.toString() ?? '');
        if (total != null && total.isFinite && total >= 0) {
          normalizedExpense
            ..['settledAmount'] = total
            ..['remainingAmount'] = 0
            ..['status'] = 'Settled';
        }
      }
      return normalizedExpense;
    }).toList();
  }

  Future<double> getWalletBalance() async {
    final snapshot = await _firestore
        .collection('wallets')
        .doc('organization')
        .get();
    final balance = snapshot.data()?['balance'];
    return balance is num ? balance.toDouble() : 0;
  }

  Stream<double> watchWalletBalance() {
    return _firestore.collection('wallets').doc('organization').snapshots().map(
      (snapshot) {
        final balance = snapshot.data()?['balance'];
        return balance is num ? balance.toDouble() : 0;
      },
    );
  }

  Future<void> addWalletTopUp(double amount) async {
    final user = _requireWalletManager();
    if (amount <= 0) {
      throw Exception('Enter a top-up amount greater than zero.');
    }

    final walletReference = _firestore
        .collection('wallets')
        .doc('organization');
    final ledgerReference = walletReference.collection('ledger').doc();
    await _firestore.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(walletReference);
      final currentBalance = walletSnapshot.data()?['balance'];
      final balance = currentBalance is num ? currentBalance.toDouble() : 0;
      transaction.set(walletReference, {
        'balance': balance + amount,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _profileEmail(user.email!),
      }, SetOptions(merge: true));
      transaction.set(ledgerReference, {
        'type': 'top-up',
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _profileEmail(user.email!),
      });
    });
  }

  Future<List<Map<String, dynamic>>> getWalletTopUpHistory() async {
    _requireWalletManager();
    final snapshot = await _firestore
        .collection('wallets')
        .doc('organization')
        .collection('ledger')
        .where('type', isEqualTo: 'top-up')
        .get();
    final entries = snapshot.docs
        .map(
          (document) => <String, dynamic>{
            ...document.data(),
            'id': document.id,
          },
        )
        .toList();
    entries.sort((first, second) {
      final firstDate = first['createdAt'];
      final secondDate = second['createdAt'];
      final firstMillis = firstDate is Timestamp
          ? firstDate.millisecondsSinceEpoch
          : 0;
      final secondMillis = secondDate is Timestamp
          ? secondDate.millisecondsSinceEpoch
          : 0;
      return secondMillis.compareTo(firstMillis);
    });
    return entries;
  }

  Future<WalletFinancialSummary> getWalletFinancialSummary() async {
    _requireWalletManager();
    final walletReference = _firestore
        .collection('wallets')
        .doc('organization');
    final walletSnapshot = await walletReference.get();
    final expenseSnapshot = await _firestore.collection('expenses').get();
    final categorySnapshot = await _firestore
        .collection('expenseCategories')
        .get();
    final ledgerSnapshot = await walletReference.collection('ledger').get();

    final categoryCompanies = <String, String>{};
    for (final document in categorySnapshot.docs) {
      final data = document.data();
      final name = data['name']?.toString().trim() ?? '';
      final company = data['company']?.toString().trim() ?? '';
      if (name.isNotEmpty && company.isNotEmpty) {
        categoryCompanies[name] = company;
      }
    }

    String companyFor(Map<String, dynamic> expense) {
      final company = expense['company']?.toString().trim() ?? '';
      if (company.isNotEmpty) return company;
      final category = expense['category']?.toString() ?? '';
      return categoryCompanies[category] ?? 'Unassigned';
    }

    double amountOf(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    final totals = <String, _CompanyExpenseAccumulator>{};
    final companyByExpenseId = <String, String>{};
    final companyExpenses = <String, List<Map<String, dynamic>>>{};
    for (final document in expenseSnapshot.docs) {
      final expense = document.data();
      final company = companyFor(expense);
      companyByExpenseId[document.id] = company;
      companyExpenses.putIfAbsent(company, () => <Map<String, dynamic>>[]).add({
        ...expense,
        'id': document.id,
        'company': company,
      });
      totals
          .putIfAbsent(company, _CompanyExpenseAccumulator.new)
          .totalExpenses += amountOf(
        expense['amount'],
      );
    }

    var totalTopUps = 0.0;
    final topUpHistory = <Map<String, dynamic>>[];
    for (final document in ledgerSnapshot.docs) {
      final entry = <String, dynamic>{...document.data(), 'id': document.id};
      if (entry['type'] == 'top-up') {
        totalTopUps += amountOf(entry['amount']);
        topUpHistory.add(entry);
      } else if (entry['type'] == 'settlement') {
        final expenseId = entry['expenseId']?.toString();
        final company = expenseId == null
            ? 'Unassigned'
            : companyByExpenseId[expenseId] ?? 'Unassigned';
        totals
            .putIfAbsent(company, _CompanyExpenseAccumulator.new)
            .walletFundedExpenses += amountOf(
          entry['amount'],
        );
      }
    }

    topUpHistory.sort((first, second) {
      final firstDate = first['createdAt'];
      final secondDate = second['createdAt'];
      final firstMillis = firstDate is Timestamp
          ? firstDate.millisecondsSinceEpoch
          : 0;
      final secondMillis = secondDate is Timestamp
          ? secondDate.millisecondsSinceEpoch
          : 0;
      return secondMillis.compareTo(firstMillis);
    });

    return WalletFinancialSummary(
      currentBalance: amountOf(walletSnapshot.data()?['balance']),
      totalTopUps: totalTopUps,
      companyTotals: {
        for (final entry in totals.entries)
          entry.key: CompanyExpenseTotals(
            totalExpenses: entry.value.totalExpenses,
            walletFundedExpenses: entry.value.walletFundedExpenses,
          ),
      },
      companyExpenses: companyExpenses,
      topUpHistory: topUpHistory,
    );
  }

  Future<void> settleWalletExpense({
    required String expenseId,
    String? groupId,
    String? contributionId,
    required double amount,
    required bool fromWallet,
  }) async {
    final user = _requireWalletSettler();
    if (expenseId.trim().isEmpty) {
      throw Exception('This transaction could not be identified.');
    }
    if (!amount.isFinite || amount <= 0) {
      throw Exception('Enter a settlement amount greater than zero.');
    }
    final amountPaise = (amount * 100).round();
    if ((amount * 100 - amountPaise).abs() > 0.000001) {
      throw Exception('Enter no more than two decimal places.');
    }
    if (groupId != null || contributionId != null) {
      if (groupId == null ||
          groupId.trim().isEmpty ||
          contributionId == null ||
          contributionId.trim().isEmpty) {
        throw Exception('This group payment could not be identified.');
      }
      await _settleEventExpenseContribution(
        groupId: groupId,
        contributionId: contributionId,
        amount: amount,
        fromWallet: fromWallet,
      );
      return;
    }
    if (expenseId.startsWith('group_')) {
      throw Exception('Select an individual group payment to settle.');
    }

    final expenseReference = _firestore.collection('expenses').doc(expenseId);
    final settledByEmail = user.email!.trim().toLowerCase();
    final profileEmail = _profileEmail(settledByEmail);
    final settlerSnapshot = await _firestore
        .collection('UserData')
        .doc(profileEmail)
        .get();
    final settledByName = settlerSnapshot.data()?['Name']?.toString().trim();
    final walletReference = _firestore
        .collection('wallets')
        .doc('organization');
    final ledgerReference = walletReference.collection('ledger').doc();

    await _firestore.runTransaction((transaction) async {
      final expenseSnapshot = await transaction.get(expenseReference);
      if (!expenseSnapshot.exists) {
        throw Exception('The transaction no longer exists.');
      }

      final expenseData = expenseSnapshot.data()!;
      if (expenseData['source']?.toString().toLowerCase() == 'prepaid') {
        throw Exception('Prepaid transactions do not need settlement.');
      }
      final expenseTotalValue = expenseData['amount'];
      if (expenseTotalValue is! num || !expenseTotalValue.isFinite) {
        throw Exception('The transaction amount is invalid.');
      }
      final expenseTotalPaise = (expenseTotalValue.toDouble() * 100).round();
      final storedSettledValue = expenseData['settledAmount'];
      var alreadySettledPaise = storedSettledValue is num
          ? (storedSettledValue.toDouble() * 100).round()
          : (double.tryParse(storedSettledValue?.toString() ?? '') ?? 0) * 100;
      if (storedSettledValue == null &&
          expenseData['status']?.toString().toLowerCase() == 'settled') {
        alreadySettledPaise = expenseTotalPaise.toDouble();
      }
      alreadySettledPaise = alreadySettledPaise.round().clamp(
        0,
        expenseTotalPaise,
      );
      final remainingPaise = expenseTotalPaise - alreadySettledPaise;
      if (remainingPaise <= 0) {
        throw Exception('This transaction is already settled.');
      }
      if (amountPaise > remainingPaise) {
        throw Exception(
          'Settlement amount cannot exceed the remaining transaction amount.',
        );
      }

      final email = _profileEmail(user.email!);
      final updatedSettledPaise = alreadySettledPaise + amountPaise;
      final updatedRemainingPaise = expenseTotalPaise - updatedSettledPaise;
      final settlementReference = expenseReference
          .collection('settlements')
          .doc();
      double? nextBalance;
      if (fromWallet) {
        final walletSnapshot = await transaction.get(walletReference);
        final currentBalance = walletSnapshot.data()?['balance'];
        final balance = currentBalance is num ? currentBalance.toDouble() : 0;
        if (amount > balance) {
          throw Exception('The wallet does not have enough balance.');
        }
        nextBalance = balance - amount;
      }

      transaction.update(expenseReference, {
        'status': updatedRemainingPaise == 0 ? 'Settled' : 'Partially Settled',
        'settledAmount': updatedSettledPaise / 100,
        'remainingAmount': updatedRemainingPaise / 100,
        'settlementSource': fromWallet ? 'Wallet' : 'Manual',
        'settledBy': email,
        'settledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(settlementReference, {
        'amountPaise': amountPaise,
        'settlementSource': fromWallet ? 'Wallet' : 'Manual',
        'settledByUid': user.uid,
        'settledByEmail': settledByEmail,
        'settledByName': settledByName?.isNotEmpty == true
            ? settledByName
            : profileEmail,
        'settledByProfileEmail': profileEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (nextBalance != null) {
        transaction.set(walletReference, {
          'balance': nextBalance,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': email,
        }, SetOptions(merge: true));
        transaction.set(ledgerReference, {
          'type': 'settlement',
          'expenseId': expenseId,
          'amount': amount,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': email,
        });
      }
    });
  }

  User _requireWalletManager() {
    final user = _auth.currentUser;
    if (user?.email?.startsWith('superadmin_') != true) {
      throw Exception('Only SuperAdmin can top up the wallet.');
    }
    return user!;
  }

  User _requireWalletSettler() {
    final user = _auth.currentUser;
    final email = user?.email;
    if (email == null ||
        !(email.startsWith('superadmin_') || email.startsWith('instructor_'))) {
      throw Exception('Only SuperAdmin or Instructor can settle transactions.');
    }
    return user!;
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    final snapshot = await _firestore.collection('UserData').get();
    final expenseSnapshot = await _firestore.collection("expenses").get();
    String? status;
    for (var t in expenseSnapshot.docs) {
      status = t.get("status");
    }
    return snapshot.docs.map((document) {
      final data = document.data();
      return <String, dynamic>{
        'email': document.id,
        'name': data['Name']?.toString() ?? 'Unnamed member',
        'role': data['role']?.toString() ?? 'Member',
        'profileImage': data['profileImage']?.toString() ?? '',
        'status': status ?? 'Pending',
        'mobile':
            data['Mobile no.']?.toString() ??
            data['Mobile no.:']?.toString() ??
            '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getExpensesByEmail(String email) async {
    final snapshot = await _firestore
        .collection('expenses')
        .where('email', isEqualTo: email)
        .get();
    final groups = await _firestore.collection('eventExpenseGroups').get();
    final expenses = await _addProfileImages(
      snapshot.docs
          .map(
            (document) => <String, dynamic>{
              ...document.data(),
              'id': document.id,
            },
          )
          .toList(),
    );
    final groupExpenses = await _getGroupContributions(
      groups.docs.map(_eventGroupAsExpense).toList(),
      memberEmail: email,
    );
    return [...expenses, ...groupExpenses];
  }

  Future<List<Map<String, dynamic>>> getAllMemberExpenses() async {
    final results = await Future.wait([
      _firestore.collection('expenses').get(),
      _firestore.collection('eventExpenseGroups').get(),
    ]);
    final expenses = await _addProfileImages(
      results[0].docs
          .map(
            (document) => <String, dynamic>{
              ...document.data(),
              'id': document.id,
            },
          )
          .toList(),
    );
    final groupExpenses = await _getGroupContributions(
      results[1].docs.map(_eventGroupAsExpense).toList(),
    );
    return [...expenses, ...groupExpenses];
  }

  Stream<List<Map<String, dynamic>>> watchExpenseCategories() {
    return _firestore
        .collection('expenseCategories')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => <String, dynamic>{
                  ...document.data(),
                  'id': document.id,
                },
              )
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    final snapshot = await _firestore
        .collection('expenseCategories')
        .orderBy('name')
        .get();
    return snapshot.docs
        .map(
          (document) => <String, dynamic>{
            ...document.data(),
            'id': document.id,
          },
        )
        .toList();
  }

  Future<void> addExpenseCategory({
    required String name,
    required String company,
    required List<String> subCategories,
  }) async {
    _requireExpenseCategoryManager();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Enter a category name.');
    }
    if (!['Incubators', 'Core2web', 'Both'].contains(company)) {
      throw Exception('Select a valid company.');
    }
    final duplicate = await _firestore
        .collection('expenseCategories')
        .where('name', isEqualTo: normalizedName)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      throw Exception('A category with this name already exists.');
    }
    await _firestore.collection('expenseCategories').add({
      'name': normalizedName,
      'company': company,
      'subCategories': _normalizeSubCategories(subCategories),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required String company,
    required List<String> subCategories,
  }) async {
    _requireExpenseCategoryManager();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Enter a category name.');
    }
    if (!['Incubators', 'Core2web', 'Both'].contains(company)) {
      throw Exception('Select a valid company.');
    }
    final duplicate = await _firestore
        .collection('expenseCategories')
        .where('name', isEqualTo: normalizedName)
        .limit(2)
        .get();
    if (duplicate.docs.any((document) => document.id != id)) {
      throw Exception('A category with this name already exists.');
    }
    await _firestore.collection('expenseCategories').doc(id).update({
      'name': normalizedName,
      'company': company,
      'subCategories': _normalizeSubCategories(subCategories),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _requireExpenseCategoryManager() {
    final email = _auth.currentUser?.email;
    if (email == null ||
        !(email.startsWith('superadmin_') || email.startsWith('instructor_'))) {
      throw Exception('Only SuperAdmin or Instructor can manage categories.');
    }
  }

  List<String> _normalizeSubCategories(List<String> values) {
    final unique = <String>{};
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) unique.add(normalized);
    }
    return unique.toList();
  }

  String _profileEmail(String authEmail) {
    for (final role in ['teamlead', 'mentor', 'instructor', 'superadmin']) {
      final prefix = '${role}_';
      if (authEmail.startsWith(prefix)) {
        return authEmail.substring(prefix.length);
      }
    }
    return authEmail;
  }
}
