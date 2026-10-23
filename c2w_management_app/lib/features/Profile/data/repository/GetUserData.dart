import 'dart:developer';

import 'package:c2w_management_app/features/expense/teamlead/data/datasources/teamlead_cloudinary.dart';
import 'package:c2w_management_app/features/Profile/data/models/UserModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/data/repository/GetEnquiryData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetUserData {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final CloudinaryDataSource cloudinaryDataSource;

  GetUserData({CloudinaryDataSource? cloudinaryDataSource})
    : cloudinaryDataSource = cloudinaryDataSource ?? CloudinaryDataSource();

  Future<UserModel?> getData(String email) async {
    try {
      log("Fetching user data for: $email");

      DocumentSnapshot<Map<String, dynamic>> document = await firebaseFirestore
          .collection("UserData")
          .doc(email)
          .get();

      if (document.exists && document.data() != null) {
        final data = document.data()!;
        final expenseSnapshot = await firebaseFirestore
            .collection('expenses')
            .where('email', isEqualTo: email)
            .get();
        var totalExpense = 0.0;
        var paidExpense = 0.0;

        for (final expense in expenseSnapshot.docs) {
          final expenseData = expense.data();
          final amount = _toAmount(expenseData['amount']);
          totalExpense += amount;

          if (expenseData['status']?.toString().trim().toLowerCase() ==
              'settled') {
            final settledAmount = _toAmount(
              expenseData['settledAmount'],
              fallback: amount,
            );
            paidExpense += settledAmount.clamp(0, amount);
          }
        }

        final enquiries = await GetEnquiryData(
          firestore: firebaseFirestore,
        ).fetchEnquiries();
        final enquiryDocumentIds = enquiries
            .map((enquiry) => enquiry.id)
            .where((id) => id.isNotEmpty)
            .toSet();

        UserModel userModel = UserModel(
          fullName: data["Name"] ?? '',
          dob: data["DOB"] ?? '',
          mobile: data["Mobile No"] ?? '',
          email: data["Email"] ?? email,
          role: data["Role"] ?? '',
          upiId: data["UPI ID"] ?? '',

          profileImage: data["profileImage"] ?? '',
          totalExpense: totalExpense,
          paidExpense: paidExpense,
          pendingExpense: totalExpense - paidExpense,
          totalEnquiries: enquiryDocumentIds.length,
        );

        log("User data fetched successfully");
        return userModel;
      } else {
        log("User not found");
        return null;
      }
    } catch (e) {
      log("Error fetching user data: $e");
      rethrow;
    }
  }

  double _toAmount(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<void> updateData({
    required String email,
    required Map<String, dynamic> updatedData,
  }) async {
    for (final key in updatedData.keys) {
      if (key.isEmpty || key.endsWith('.')) {
        throw ArgumentError('Invalid Firestore field name: "$key"');
      }
    }

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(email)
        .update(updatedData);
  }

  Future<void> updateProfileImage({
    required String email,
    required String filePath,
  }) async {
    final imageUrl = await cloudinaryDataSource.uploadProfileImage(
      filePath: filePath,
      email: email,
    );
    await updateData(email: email, updatedData: {'profileImage': imageUrl});
  }
}
