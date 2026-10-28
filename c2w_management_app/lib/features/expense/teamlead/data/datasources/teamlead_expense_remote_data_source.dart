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
      return {...expense, 'profileImage': profileImages[email] ?? ''};
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
    required double amount,
    required bool fromWallet,
  }) async {
    final user = _requireWalletSettler();
    if (expenseId.trim().isEmpty) {
      throw Exception('This transaction could not be identified.');
    }
    if (amount <= 0) {
      throw Exception('Enter a settlement amount greater than zero.');
    }

    final expenseReference = _firestore.collection('expenses').doc(expenseId);
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
      if (expenseData['status']?.toString().toLowerCase() == 'settled') {
        throw Exception('This transaction is already settled.');
      }
      final expenseTotal = expenseData['amount'];
      if (expenseTotal is! num || amount > expenseTotal.toDouble()) {
        throw Exception(
          'Settlement amount cannot exceed the transaction total.',
        );
      }

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

      final email = _profileEmail(user.email!);
      transaction.update(expenseReference, {
        'status': 'settled',
        'settledAmount': amount,
        'settlementSource': fromWallet ? 'Wallet' : 'Manual',
        'settledBy': email,
        'settledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
