class UserModel {
  // Profile details
  final String fullName;
  final String dob;
  final String mobile;
  final String email;
  final String upiId;
  final String profileImage;
  final String role;

  // Dashboard statistics
  final double totalExpense;
  final double pendingExpense;
  final double paidExpense;
  final int totalEnquiries;

  const UserModel({
    required this.fullName,
    required this.dob,
    required this.mobile,
    required this.email,
    required this.upiId,
    this.profileImage = '',
    this.role = 'Admin',
    this.totalExpense = 0,
    this.pendingExpense = 0,
    this.paidExpense = 0,
    this.totalEnquiries = 0,
  });

  // Convert model to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dob': dob,
      'mobile': mobile,
      'email': email,
      'upiId': upiId,
      'profileImage': profileImage,
      'role': role,
      'totalExpense': totalExpense,
      'pendingExpense': pendingExpense,
      'paidExpense': paidExpense,
      'totalEnquiries': totalEnquiries,
    };
  }

  // Convert Firestore Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {     //map to obj
    return UserModel(
      fullName: map['fullName'] ?? '',
      dob: map['dob'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      upiId: map['upiId'] ?? '',
      profileImage: map['profileImage'] ?? '',
      role: map['role'] ?? 'Admin',
      totalExpense: (map['totalExpense'] as num?)?.toDouble() ?? 0,
      pendingExpense: (map['pendingExpense'] as num?)?.toDouble() ?? 0,
      paidExpense: (map['paidExpense'] as num?)?.toDouble() ?? 0,
      totalEnquiries: (map['totalEnquiries'] as num?)?.toInt() ?? 0,
    );
  }
}