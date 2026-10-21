
import 'package:equatable/equatable.dart';

class LoginSignupState extends Equatable {
  final String? name;
  final String? email;
  final String? mob;
  final String? upi;
  final String? dob;
  final String? pass;
  final String? role;

  const LoginSignupState({
    this.name,this.email,this.mob,this.upi,this.dob,this.pass,this.role
  });

  @override
  List<Object?> get props => [name,email,mob,upi,dob,pass];
}

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

//Login state
class LoginInitial extends LoginSignupState {}

class LoginLoading extends LoginSignupState {}

class LoginSuccessful extends LoginSignupState {}

class LoginInvalidCredentials extends LoginSignupState {}

class LoginFailure extends LoginSignupState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
//signUP states

class SignupInitial extends LoginSignupState {}

class SignupLoading extends LoginSignupState {}

class SignupSuccessful extends LoginSignupState {}

class SignupInvalidCredentials extends LoginSignupState {}

class SignupFailure extends LoginSignupState {
  final String message;

  const SignupFailure(this.message);

  @override
  List<Object?> get props => [...super.props,message];
}
