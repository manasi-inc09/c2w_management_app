import 'dart:developer';

import 'package:c2w_management_app/features/Profile/data/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetUserData {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<UserModel?> getData(String email) async {
    try {
      log("Fetching user data for: $email");

      DocumentSnapshot<Map<String, dynamic>> document = await firebaseFirestore
          .collection("UserData")
          .doc(email)
          .get();

      if (document.exists && document.data() != null) {
        final data = document.data()!;

        UserModel userModel = UserModel(
          fullName: data["Name"] ?? '',
          dob: data["DOB"] ?? '',
          mobile: data["Mobile No"] ?? '',
          email: data["Email"] ?? email,
          role: data["Role"] ?? '',
          upiId: data["UPI ID"] ?? '',

          profileImage: data["profileImage"] ?? '',
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
}
