
import 'package:equatable/equatable.dart';

abstract class LoginSignupEvent extends Equatable {
  const LoginSignupEvent();


  @override
  List<Object?> get props => [];
}

class LoginEvent extends LoginSignupEvent {
  final String email;
  final String pass;
  final String role;

  LoginEvent(this.email, this.pass,this.role){
    print("Event...........${email}");
    print(pass);
  }
  @override
  List<Object?> get props => [email, pass,role];
}

class SignupAuthEvent extends LoginSignupEvent {
  final String email;
  final String pass;
   final String role;

  const SignupAuthEvent(this.email, this.pass,this.role);

  @override
  List<Object?> get props => [email, pass,role];
}

class SignupDataEvent extends LoginSignupEvent {
  final String name;
  final String email;
  final String mob;
  final String upi;
  final String dob;
  final String pass;
  final String role;

  const SignupDataEvent(this.name,this.email,this.mob,this.upi,this.dob,this.pass,this.role);

  @override
  List<Object?> get props => [name,email,mob,upi,dob,pass,role];
}
