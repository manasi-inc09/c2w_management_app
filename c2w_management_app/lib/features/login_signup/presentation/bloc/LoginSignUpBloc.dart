import 'dart:developer';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
// import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Loginsignupbloc extends Bloc<LoginSignupEvent, LoginSignupState> {
  final AuthRepository _authRepository = AuthRepository();

  Loginsignupbloc() : super(LoginSignupState()) {
    on<LoginEvent>((event, emit) async {
      print("Login Event Called");
      print("Bloc Email: ${event.email}");
      emit(LoginLoading());
      try {
        await _authRepository.loginUser(
          email: event.email,
          pass: event.pass,
          role: event.role,
        );
        var sessionSaved = true;
        try {
          await _authRepository.saveLoginStatus();
        } catch (error, stackTrace) {
          sessionSaved = false;
          log(
            'Firebase login succeeded, but session status could not be saved: $error',
            stackTrace: stackTrace,
          );
        }
        emit(LoginSuccessful(sessionSaved: sessionSaved));
      } on FirebaseException catch (e) {
        if (e.code == 'invalid-credential' ||
            e.code == 'wrong-password' ||
            e.code == 'user-not-found' ||
            e.code == 'invalid-email') {
          emit(LoginInvalidCredentials());
        } else {
          emit(LoginFailure(e.message ?? 'Login failed'));
        }
      } catch (e, stackTrace) {
        log('Login failed unexpectedly: $e', stackTrace: stackTrace);
        emit(LoginFailure('Please enter valid credentials.'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(LogoutLoading());
      try {
        await _authRepository.clearLoginStatus();
        await _authRepository.signOutFirebase();
        emit(LogoutSuccessful());
      } catch (error, stackTrace) {
        log('Logout failed: $error', stackTrace: stackTrace);
        emit(LogoutFailure('Could not log out. Please try again.'));
      }
    });

    on<SignupAuthEvent>((event, emit) async {
      print("SignUp auth Event Called");
      print("Email: ${event.email}");
      emit(LoginSignupState(email: event.email, role: event.role));
      try {
        await _authRepository.signupUser(email: event.email, pass: event.pass,role: event.role);
      } on FirebaseException catch (e) {
        print(e.message);
      }
      print("SignUp Auth emitted");
    });

    on<SignupDataEvent>((event, emit) async {
      print("Signup Event Called");
      print("Name: ${event.name}");

      emit(SignupLoading());

      try {
        await _authRepository.signupdata(
          name: event.name,
          email: event.email,
          mobno: event.mob,
          upi: event.upi,
          dob: event.dob,
          role: event.role,
        );

        emit(SignupSuccessful());
        log("Signup Successful");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          emit(SignupInvalidCredentials());
        } else {
          emit(SignupFailure(e.message ?? 'Signup failed'));
        }

        log("Signup Error: ${e.message}");
      } on FirebaseException catch (e) {
        emit(SignupFailure(e.message ?? 'Failed to save signup data'));
        log("Firebase Error: ${e.message}");
      } catch (e) {
        emit(SignupFailure('Something went wrong'));
        log("Signup Error: $e");
      }
    });
  }
}
