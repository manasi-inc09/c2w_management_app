import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserDataEvent extends ProfileEvent {
  final String email;

  const GetUserDataEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class UpdateUserDataEvent extends ProfileEvent {
  final String email;
  final Map<String, dynamic> updatedData;

  const UpdateUserDataEvent({
    required this.email,
    required this.updatedData,
    
  });
  
  @override
  List<Object?> get props => [email, updatedData];
}