import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _loginStatusKey = 'is_logged_in';
  static const String _userCreationAppName = 'user-creation';
  static FirebaseApp? _userCreationApp;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  UserCredential? userCredential;
  Map<String, dynamic>? obj;
  static String? authEmail;

  static const Map<String, String> _roleAliases = {
    'salesadmin': 'salesadmin',
    'sales admin': 'salesadmin',
    'teamlead': 'teamlead',
    'team lead': 'teamlead',
    'mentor': 'mentor',
    'instructor': 'instructor',
    'superadmin': 'superadmin',
    'super admin': 'superadmin',
  };

  static String normalizeRole(String role) {
    final normalized = role.trim().toLowerCase().replaceAll('_', ' ');
    return _roleAliases[normalized] ?? normalized.replaceAll(' ', '');
  }

  static String cleanEmail(String? email) {
    final trimmed = (email ?? '').trim();
    if (trimmed.isEmpty) return '';
    return trimmed.replaceFirst(
      RegExp(
        r'^(superadmin|salesadmin|teamlead|instructor|mentor|admin)_',
        caseSensitive: false,
      ),
      '',
    );
  }

  static Future<bool> isProfileComplete({String? email}) async {
    final resolvedEmail = cleanEmail(
      email ?? authEmail ?? FirebaseAuth.instance.currentUser?.email,
    );
    if (resolvedEmail.isEmpty) return false;

    try {
      final data = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(resolvedEmail)
          .get();

      if (!data.exists || data.data() == null) return false;

      final userData = data.data()!;
      final requiredFields = [
        userData['Mobile No'],
        userData['UPI ID'],
        userData['DOB'],
        userData['profileImage'],
      ];

      return requiredFields.every(
        (field) => field != null && field.toString().trim().isNotEmpty,
      );
    } catch (error, stackTrace) {
      log('Profile completeness check failed: $error', stackTrace: stackTrace);
      return false;
    }
  }

  Future<UserCredential> loginUser({
    required String email,
    required String pass,
    required String role,
  }) async {
    final normalizedRole = normalizeRole(role);
    final normalizedEmail = cleanEmail(email).toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email is required to log in.');
    }

    final userData = await _firebaseFirestore
        .collection('UserData')
        .doc(normalizedEmail)
        .get();
    final registeredRole = userData.data()?['Role']?.toString();
    if (registeredRole != null &&
        registeredRole.trim().isNotEmpty &&
        normalizeRole(registeredRole) != normalizedRole) {
      throw LoginRoleMismatchException();
    }

    try {
      authEmail = '${normalizedRole}_$normalizedEmail';
      log('login email : $authEmail');
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: authEmail!,
        password: pass,
      );

      log('UserCredentials : $userCredential');
    } on FirebaseAuthException catch (err) {
      authEmail = null;
      log('Login failed: ${err.message}');
      rethrow;
    }
    return userCredential!;
  }

  /// Saves only whether a user has an active app login. Never save passwords.
  Future<void> saveLoginStatus() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_loginStatusKey, true);
  }

  /// Returns true when the user previously completed a successful login.
  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_loginStatusKey) ?? false;
  }

  /// Removes the saved login status from local preferences.
  Future<void> clearLoginStatus() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_loginStatusKey);
  }

  Future<void> signOutFirebase() async {
    await _firebaseAuth.signOut();
    authEmail = null;
  }

  Future<UserCredential> signupUser({
    required String email,
    required String pass,
    required String role,
  }) async {
    role = role.toLowerCase();
    final createdEmail = '${role}_$email';

    final app = _userCreationApp ??= await Firebase.initializeApp(
      name: _userCreationAppName,
      options: Firebase.app().options,
    );
    final creationAuth = FirebaseAuth.instanceFor(app: app);

    try {
      log('creating user email : $createdEmail');
      final credential = await creationAuth.createUserWithEmailAndPassword(
        email: createdEmail,
        password: pass,
      );

      try {
        await creationAuth.signOut();
      } catch (error, stackTrace) {
        log(
          'Created user but could not sign out the isolated account: $error',
          stackTrace: stackTrace,
        );
      }

      return credential;
    } on FirebaseAuthException catch (error) {
      log('User creation failed: ${error.message}');
      rethrow;
    }
  }

  Future<void> signupdata({
    required String name,
    required String email,
    required String mobno,
    required String upi,
    required String dob,
    required String role,
  }) async {
    role = role.toLowerCase();
    final userData = <String, dynamic>{
      'Name': name,
      'Email': email,
      'Role': role,
    };

    if (mobno.trim().isNotEmpty) {
      userData['Mobile No'] = mobno.trim();
    }
    if (upi.trim().isNotEmpty) {
      userData['UPI ID'] = upi.trim();
    }
    if (dob.trim().isNotEmpty) {
      userData['DOB'] = dob.trim();
    }

    obj = userData;
    log('data adding in firebase.................');
    return await _firebaseFirestore.collection('UserData').doc(email).set(obj!);
  }
}

class LoginRoleMismatchException implements Exception {
  const LoginRoleMismatchException();
}
