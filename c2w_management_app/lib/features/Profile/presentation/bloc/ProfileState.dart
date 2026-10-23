import 'package:equatable/equatable.dart';
import 'package:c2w_management_app/features/Profile/data/models/UserModel.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ProfileInitial extends ProfileState {}

// Loading state
class ProfileLoading extends ProfileState {}

// Success state
class ProfileSuccess extends ProfileState {
  final UserModel user;

  const ProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// User not found state
class ProfileNotFound extends ProfileState {}

// Failure state
class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateFailure extends ProfileState {
  final String message;

  const ProfileUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}