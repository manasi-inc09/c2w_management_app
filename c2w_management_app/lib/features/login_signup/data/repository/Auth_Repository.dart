

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
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
      authEmail = "_$role$email";
      log("login email : _$role$email");
       userCredential = await  _firebaseAuth
                  .signInWithEmailAndPassword(email:email,password: pass);

      log("UserCredentials : ${userCredential}");
    }on FirebaseAuthException catch (err){

      log(" error message ${err.message}");
    }
    return userCredential!;
  }

  Future<UserCredential> signupUser({
    required String email,
    required String pass,
  })async{
    try{
       userCredential = await  _firebaseAuth
                  .createUserWithEmailAndPassword(email:email,password: pass);
    }on FirebaseAuthException catch (err){
      log("${err.message}");
    }
    return userCredential!;
  }

  Future<void> signupdata({
    required String name,
    required String email,
    required String mobno,
    required String upi,
    required String dob,
    required String pass,
    required String role,
  })async{
    role=role.toLowerCase();
    try{
      print("in repo email: ${email}");
      log("_${role}${email}");
     obj = {
                  "Name":name,
                  "Email":"_$role$email",
                  "Mobile no.:":mobno,
                  "UPI ID":upi,
                  "DOB":dob,
                  "Password":pass,
                  "role":role
                 
                };
                log("data adding in firebase.................");
    }on FirebaseException catch (err){
      log("${err.message}");
    }
    return await _firebaseFirestore.collection("UserData").doc(email).set(obj!);
         
    
  }



}