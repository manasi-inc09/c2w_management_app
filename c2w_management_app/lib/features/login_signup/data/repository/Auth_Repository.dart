

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _loginStatusKey = 'is_logged_in';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  UserCredential? userCredential;
  Map<String,dynamic>? obj ;
   static String? authEmail;

  Future<UserCredential> loginUser({
    required String email,
    required String pass,
    required String role,

  }) async{
    role=role.toLowerCase();
    try{
      authEmail = "${role}_$email";
      log("login email : ${role}_$email");
       userCredential = await  _firebaseAuth
                  .signInWithEmailAndPassword(email:authEmail!,password: pass);

      log("UserCredentials : ${userCredential}");
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

  }) async{
    role=role.toLowerCase();
    try{
      authEmail = "${role}_$email";
      log("login email : ${role}_$email");
       userCredential = await  _firebaseAuth
                  .createUserWithEmailAndPassword(email:authEmail!,password: pass);

      // log("UserCredentials : ${userCredential}");
    }on FirebaseAuthException catch (err){

      log(" error message ${err.message}");
    }
    return userCredential!;
  }

  Future<void> signupdata({
    required String name,
    required String email,
    required String mobno,
    required String upi,
    required String dob,
    required String role,
  })async{
    role=role.toLowerCase();
    try{
      print("in repo email: ${email}");
      log("${role}_${email}");
     obj = {
                  "Name":name,
                  "Email":email,
                  "Mobile No":mobno,
                  "UPI ID":upi,
                  "DOB":dob,
                  "Role":role
                 
                };
                log("data adding in firebase.................");
    }on FirebaseException catch (err){
      log("${err.message}");
    }
    return await _firebaseFirestore.collection("UserData").doc(email).set(obj!);
         
    
  }



}
