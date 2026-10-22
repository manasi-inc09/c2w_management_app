import 'dart:developer';

import 'package:c2w_management_app/features/Profile/data/repository/GetUserdata.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileEvent.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileState.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserData getUserData;

  ProfileBloc(this.getUserData) : super(ProfileInitial()) {
    on<GetUserDataEvent>((event, emit) async {
      emit(ProfileLoading());

      try {
        log('Fetching profile for ${event.email}');

        final user = await getUserData.getData(event.email);

        if (user != null) {
          emit(ProfileSuccess(user));
          log('Profile fetched successfully');
        } else {
          emit(ProfileNotFound());
          log('User not found');
        }
      } catch (e) {
        log('Profile fetch failed: $e');
        emit(ProfileFailure('Failed to load profile'));
      }
    });

     on<UpdateUserDataEvent>((event, emit) async {
      emit(ProfileUpdateLoading());

      log("${event.updatedData.length}");

      try {
        await getUserData.updateData(
          email: event.email,
          updatedData: event.updatedData,
        );

        final updatedUser = await getUserData.getData(event.email);

        if (updatedUser == null) {
          emit(
            ProfileUpdateFailure(
              'Profile was updated, but could not be reloaded.',
            ),
          );
          return;
        }

        emit(ProfileUpdateSuccess(updatedUser));

        // Refresh the ProfileScreen with the latest user data.
        emit(ProfileSuccess(updatedUser));

        log('Profile updated successfully');
      } catch (e, stackTrace) {
        log(
          'Profile update failed',
          error: e,
          stackTrace: stackTrace,
        );

        emit(
          ProfileUpdateFailure(
            'Failed to update profile. Please try again.',
          ),
        );
      }
    });
  }
}