import 'dart:developer';

import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      'subCategory': expense.subCategory,

      'receiptUrl': receiptUrl,
      'status': 'Pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await expenseReference.set(expenseData);
    return expenseId;
  }

  Stream<List<Map<String, dynamic>>> watchExpensesByEmail(String email) {
    return _firestore
        .collection('expenses')
        .where('email', isEqualTo: email)
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

  Stream<List<Map<String, dynamic>>> watchAllExpenses() {
    return _firestore
        .collection('expenses')
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

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    return snapshot.docs
        .map(
          (document) => <String, dynamic>{
            ...document.data(),
            'id': document.id,
          },
        )
        .toList();
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
    final expenseSnapshot=await _firestore.collection("expenses").get();
    String? status;
    for(var t in expenseSnapshot.docs){
      status=t.get("status");
    }
    return snapshot.docs.map((document) {
      final data = document.data();
      return <String, dynamic>{
        'email': document.id,
        'name': data['Name']?.toString() ?? 'Unnamed member',
        'role': data['role']?.toString() ?? 'Member',
        'status':status??'Pending',
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
    return snapshot.docs
        .map(
          (document) => <String, dynamic>{
            ...document.data(),
            'id': document.id,
          },
        )
        .toList();
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
    required List<String> subCategories,
  }) async {
    _requireExpenseCategoryManager();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Enter a category name.');
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
      'subCategories': _normalizeSubCategories(subCategories),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateExpenseCategory({
    required String id,
    required String name,
    required List<String> subCategories,
  }) async {
    _requireExpenseCategoryManager();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw Exception('Enter a category name.');
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
