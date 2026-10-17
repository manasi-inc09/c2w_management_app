import 'package:bloc/bloc.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Loginsignupbloc extends Bloc<LoginSignupEvent, LoginSignupState> {

  final AuthRepository _authRepository = AuthRepository();

  Loginsignupbloc() : super( LoginSignupState()) {

    on<LoginEvent>((event, emit) {
      print("Login Event Called");
    print("Bloc Email: ${event.email}");
      emit(LoginSignupState(
        email: event.email,
        pass: event.pass,
      ));
      try{
        
      _authRepository.loginUser(email: event.email,pass: event.pass);
      }on FirebaseException catch(e){
        print(e.message);
      }
      print("Login emitted");
    });

    on<SignUpAuthEvent>((event, emit) {
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

    on<SignupEvent>((event, emit) {
      print("Signup Event Called");
      print("Name: ${event.name}");
      emit(LoginSignupState(

        name: event.name,
        mobno: event.mobno,
        email: event.email,
        pass: event.pass,
      ));
      try{
      _authRepository.signupdata(email:event.email ,pass: event.pass,name: event.name,mobno: event.mobno);
      }
      on FirebaseException catch(e){
        print(e.message);
      }
      print("SignUp emitted");
    });
  }
}
