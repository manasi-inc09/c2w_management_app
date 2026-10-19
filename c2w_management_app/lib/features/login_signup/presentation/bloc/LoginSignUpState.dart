
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
