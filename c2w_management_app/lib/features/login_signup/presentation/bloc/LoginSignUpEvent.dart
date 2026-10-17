
import 'package:equatable/equatable.dart';

abstract class LoginSignupEvent extends Equatable {
  const LoginSignupEvent();


  @override
  List<Object?> get props => [];
}

class LoginEvent extends LoginSignupEvent {
  final String email;
  final String pass;

  LoginEvent(this.email, this.pass){
    print("Event...........${email}");
    print(pass);
  }
  @override
  List<Object?> get props => [email, pass];
}

class SignUpAuthEvent extends LoginSignupEvent {
  final String email;
  final String pass;

  const SignUpAuthEvent(this.email, this.pass);

  @override
  List<Object?> get props => [email, pass];
}

class SignupEvent extends LoginSignupEvent {
  final String name;
  final String mobno;
  final String email;
  final String pass;

  const SignupEvent(this.name, this.mobno, this.email, this.pass);

  @override
  List<Object?> get props => [name, mobno, email, pass];
}
