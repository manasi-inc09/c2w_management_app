

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<UserCredential> loginUser({
    required String email,
    required String pass
  }) async{
    final userCredential = await  _firebaseAuth
                  .signInWithEmailAndPassword(email:email,password: pass);
    return userCredential;
  }

  Future<UserCredential> signupUser({
    required String email,
    required String pass,
  })async{
    final userCredential = await  _firebaseAuth
                  .createUserWithEmailAndPassword(email:email,password: pass);
    return userCredential;
  }

  Future<void> signupdata({
    required String email,
    required String pass,
    required String name,
    required String mobno
  })async{
    print("in repo email: ${email}");
    Map<String,dynamic> obj = {
                  "Name":name,
                  "Mobile no.:":mobno,
                  "email":email,
                  "pass":pass
                 
                };
                print("data adding.................");
    return await _firebaseFirestore.collection("UserData").doc(email).set(obj);
         
    
  }



}