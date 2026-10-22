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

    final userDocument = await _firestore
        .collection('UserData')
        .doc(email)
        .get();

    if (!userDocument.exists) {
      throw Exception('User profile was not found.');
    }

    final userData = userDocument.data()!;

    if (userData['isActive'] == false) {
      throw Exception('Your account is inactive.');
    }

    final claimantName =
        (userData['Name'] as String?) ?? user.displayName ?? 'Unknown User';

    final claimantRole = userData['role'] as String?;

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

  Future<List<Map<String, dynamic>>> getMembers() async {
    final snapshot = await _firestore.collection('UserData').get();
    return snapshot.docs
        .map((document) {
          final data = document.data();
          return <String, dynamic>{
            'email': document.id,
            'name': data['Name']?.toString() ?? 'Unnamed member',
            'role': data['role']?.toString() ?? 'Member',
            'mobile': data['Mobile no.']?.toString() ??
                data['Mobile no.:']?.toString() ??
                '',
          };
        })
        .toList();
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
