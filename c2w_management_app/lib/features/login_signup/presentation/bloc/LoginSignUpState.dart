import 'package:equatable/equatable.dart';

class LoginSignupState extends Equatable {
  final String? name;
  final String? email;
  final String? mob;
  final String? upi;
  final String? dob;
  final String? role;

  const LoginSignupState({
    this.name,
    this.email,
    this.mob,
    this.upi,
    this.dob,
    this.role,
  });

  @override
  List<Object?> get props => [name, email, mob, upi, dob, role];
}

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

//Login state
class LoginInitial extends LoginSignupState {}

class LoginLoading extends LoginSignupState {}

class LoginSuccessful extends LoginSignupState {
  final bool sessionSaved;

  const LoginSuccessful({this.sessionSaved = true});

  @override
  List<Object?> get props => [sessionSaved];
}

class LoginInvalidCredentials extends LoginSignupState {}

class LoginRoleMismatch extends LoginSignupState {}

class LoginFailure extends LoginSignupState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LogoutLoading extends LoginSignupState {}

class LogoutSuccessful extends LoginSignupState {}

class LogoutFailure extends LoginSignupState {
  final String message;

  const LogoutFailure(this.message);

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
  List<Object?> get props => [...super.props, message];
}
