
import 'package:equatable/equatable.dart';

class LoginSignupState extends Equatable {
  final String? name;
  final String? mobno;
  final String? email;
  final String? pass;

  const LoginSignupState({
    this.name,
    this.mobno,
    this.email,
    this.pass,
  });

  @override
  List<Object?> get props => [name, mobno, email, pass];
}
