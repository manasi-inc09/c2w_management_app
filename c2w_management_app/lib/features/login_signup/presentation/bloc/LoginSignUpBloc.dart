import 'dart:developer';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Loginsignupbloc extends Bloc<LoginSignupEvent, LoginSignupState> {

  final AuthRepository _authRepository = AuthRepository();

  Loginsignupbloc() : super( LoginSignupState()) {

    on<LoginEvent>((event, emit) {
      print("Login Event Called");
    print("Bloc Email: ${event.email}");
      emit(LoginSignupState(
        email: event.email,
        pass: event.pass,
        role: event.role,
      ));
      try{
        
      _authRepository.loginUser(email: event.email,pass: event.pass,role: event.role);
      }on FirebaseException catch(e){
        print(e.message);
      }
      log("Login emitted");
    });

    on<SignupAuthEvent>((event, emit) {
      print("SignUp auth Event Called");
    print("Email: ${event.email}");
      emit(LoginSignupState(
        email: event.email,
        pass: event.pass,
      ));
      try{
    _authRepository.signupUser(email: event.email,pass: event.pass);
      }
      on FirebaseException catch(e){
        print(e.message);
      }
      print("SignUp Auth emitted");
    });

    on<SignupDataEvent>((event, emit) {
      print("Signup Event Called");
      print("Name: ${event.name}");
      emit(LoginSignupState(
        name: event.name,
        email: event.email,
        mob: event.mob,
        upi: event.upi,
        dob: event.dob,        
        pass: event.pass,
        role: event.role
      ));
      try{
      _authRepository.signupdata(name: event.name,email:event.email ,mobno: event.mob,upi: event.upi,dob: event.dob,pass: event.pass,role: event.role);
      }
      on FirebaseException catch(e){
        print(e.message);
      }
      log("SignUp emitted");
    });
  }
}
