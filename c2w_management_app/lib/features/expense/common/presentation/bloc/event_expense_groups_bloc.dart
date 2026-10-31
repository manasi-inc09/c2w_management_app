import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EventExpenseGroupsEvent {}

class EventExpenseGroupsStarted extends EventExpenseGroupsEvent {
  final String userUid;
  final String userEmail;

  EventExpenseGroupsStarted({
    required this.userUid,
    required this.userEmail,
  });
}

class EventExpenseGroupsSnapshotReceived extends EventExpenseGroupsEvent {
  final QuerySnapshot<Map<String, dynamic>> snapshot;

  EventExpenseGroupsSnapshotReceived(this.snapshot);
}

class EventExpenseGroupsSnapshotFailed extends EventExpenseGroupsEvent {
  final String error;

  EventExpenseGroupsSnapshotFailed(this.error);
}

class EventGroupUsersRequested extends EventExpenseGroupsEvent {}

class EventGroupUsersReceived extends EventExpenseGroupsEvent {
  final List<Map<String, dynamic>> users;

  EventGroupUsersReceived(this.users);
}

class EventGroupUsersFailed extends EventExpenseGroupsEvent {
  final String error;

  EventGroupUsersFailed(this.error);
}

class EventGroupCreateRequested extends EventExpenseGroupsEvent {
  final User user;
  final String eventName;
  final String expensePurpose;
  final Set<String> selectedMemberEmails;

  EventGroupCreateRequested({
    required this.user,
    required this.eventName,
    required this.expensePurpose,
    required this.selectedMemberEmails,
  });
}

class EventGroupAccessUpdateRequested extends EventExpenseGroupsEvent {
  final User user;
  final String groupId;
  final String creatorEmail;
  final Set<String> memberEmails;

  EventGroupAccessUpdateRequested({
    required this.user,
    required this.groupId,
    required this.creatorEmail,
    required this.memberEmails,
  });
}

class EventExpenseGroupsState {
  final List<Map<String, dynamic>> groups;
  final List<Map<String, dynamic>> users;
  final bool groupsLoading;
  final bool usersLoading;
  final String? groupsError;
  final String? usersError;
  final String? operationError;

  const EventExpenseGroupsState({
    this.groups = const [],
    this.users = const [],
    this.groupsLoading = true,
    this.usersLoading = true,
    this.groupsError,
    this.usersError,
    this.operationError,
  });

  EventExpenseGroupsState copyWith({
    List<Map<String, dynamic>>? groups,
    List<Map<String, dynamic>>? users,
    bool? groupsLoading,
    bool? usersLoading,
    String? groupsError,
    String? usersError,
    String? operationError,
    bool clearGroupsError = false,
    bool clearUsersError = false,
    bool clearOperationError = false,
  }) {
    return EventExpenseGroupsState(
      groups: groups ?? this.groups,
      users: users ?? this.users,
      groupsLoading: groupsLoading ?? this.groupsLoading,
      usersLoading: usersLoading ?? this.usersLoading,
      groupsError: clearGroupsError ? null : groupsError ?? this.groupsError,
      usersError: clearUsersError ? null : usersError ?? this.usersError,
      operationError: clearOperationError
          ? null
          : operationError ?? this.operationError,
    );
  }
}

class EventExpenseGroupsBloc
    extends Bloc<EventExpenseGroupsEvent, EventExpenseGroupsState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _groupsSubscription;
  String? _userUid;
  String _userEmail = '';

  EventExpenseGroupsBloc({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const EventExpenseGroupsState()) {
    on<EventExpenseGroupsStarted>(_onStarted);
    on<EventExpenseGroupsSnapshotReceived>(_onSnapshotReceived);
    on<EventExpenseGroupsSnapshotFailed>(_onSnapshotFailed);
    on<EventGroupUsersRequested>(_onUsersRequested);
    on<EventGroupUsersReceived>(_onUsersReceived);
    on<EventGroupUsersFailed>(_onUsersFailed);
    on<EventGroupCreateRequested>(_onCreateRequested);
    on<EventGroupAccessUpdateRequested>(_onAccessUpdateRequested);
  }

  Future<void> _onStarted(
    EventExpenseGroupsStarted event,
    Emitter<EventExpenseGroupsState> emit,
  ) async {
    _userUid = event.userUid;
    _userEmail = event.userEmail.trim().toLowerCase();
    await _groupsSubscription?.cancel();
    _groupsSubscription = _firestore
        .collection('eventExpenseGroups')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) => add(EventExpenseGroupsSnapshotReceived(snapshot)),
          onError: (Object error) =>
              add(EventExpenseGroupsSnapshotFailed(error.toString())),
        );
    add(EventGroupUsersRequested());
  }

  void _onSnapshotReceived(
    EventExpenseGroupsSnapshotReceived event,
    Emitter<EventExpenseGroupsState> emit,
  ) {
    final groups = event.snapshot.docs
        .map(
          (document) => <String, dynamic>{
            ...document.data(),
            'id': document.id,
          },
        )
        .where(_hasGroupAccess)
        .toList();
    emit(
      state.copyWith(
        groups: groups,
        groupsLoading: false,
        clearGroupsError: true,
      ),
    );
  }

  void _onSnapshotFailed(
    EventExpenseGroupsSnapshotFailed event,
    Emitter<EventExpenseGroupsState> emit,
  ) {
    emit(state.copyWith(groupsLoading: false, groupsError: event.error));
  }

  Future<void> _onUsersRequested(
    EventGroupUsersRequested event,
    Emitter<EventExpenseGroupsState> emit,
  ) async {
    emit(state.copyWith(usersLoading: true, clearUsersError: true));
    try {
      final snapshot = await _firestore.collection('UserData').get();
      final users = snapshot.docs
          .map((document) {
            final data = document.data();
            final authEmail = _authEmailForUser(data);
            if (authEmail == null) return null;
            return <String, dynamic>{
              ...data,
              'authEmail': authEmail,
              'displayName': data['Name']?.toString().trim().isNotEmpty == true
                  ? data['Name'].toString().trim()
                  : authEmail,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();
      add(EventGroupUsersReceived(users));
    } catch (error) {
      add(EventGroupUsersFailed(error.toString()));
    }
  }

  void _onUsersReceived(
    EventGroupUsersReceived event,
    Emitter<EventExpenseGroupsState> emit,
  ) {
    emit(
      state.copyWith(
        users: event.users,
        usersLoading: false,
        clearUsersError: true,
      ),
    );
  }

  void _onUsersFailed(
    EventGroupUsersFailed event,
    Emitter<EventExpenseGroupsState> emit,
  ) {
    emit(state.copyWith(usersLoading: false, usersError: event.error));
  }

  Future<void> _onCreateRequested(
    EventGroupCreateRequested event,
    Emitter<EventExpenseGroupsState> emit,
  ) async {
    emit(state.copyWith(clearOperationError: true));
    try {
      final user = event.user;
      _ensureGroupManager(user.email);
      final email = user.email!.trim().toLowerCase();
      final usersSnapshot = await _firestore.collection('UserData').get();
      final allEmails = usersSnapshot.docs
          .map((document) => _authEmailForUser(document.data()))
          .whereType<String>()
          .toSet();
      final adminEmails = allEmails.where(_isEventGroupAdmin).toSet();
      final profile = await _firestore
          .collection('UserData')
          .doc(_profileEmail(email))
          .get();
      final name =
          profile.data()?['Name']?.toString().trim().isNotEmpty == true
          ? profile.data()!['Name'].toString().trim()
          : user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : _profileEmail(email);

      await _firestore.collection('eventExpenseGroups').add({
        'eventName': event.eventName,
        'expensePurpose': event.expensePurpose,
        'createdByUid': user.uid,
        'createdByEmail': email,
        'createdByName': name,
        'memberEmails': {
          ...event.selectedMemberEmails,
          ...adminEmails,
          email,
        }.toList(),
        'totalAmountPaise': 0,
        'settledAmountPaise': 0,
        'contributionCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(state.copyWith(operationError: 'Could not create the event group: $error'));
    }
  }

  Future<void> _onAccessUpdateRequested(
    EventGroupAccessUpdateRequested event,
    Emitter<EventExpenseGroupsState> emit,
  ) async {
    emit(state.copyWith(clearOperationError: true));
    try {
      _ensureGroupManager(event.user.email);
      await _firestore.collection('eventExpenseGroups').doc(event.groupId).update({
        'memberEmails': {...event.memberEmails, event.creatorEmail}.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(state.copyWith(operationError: 'Could not update group access: $error'));
    }
  }

  bool _hasGroupAccess(Map<String, dynamic> group) {
    final memberEmails = group['memberEmails'];
    if (memberEmails is List) {
      return memberEmails.any(
        (memberEmail) =>
            memberEmail?.toString().trim().toLowerCase() == _userEmail,
      );
    }
    return _userUid != null && group['createdByUid']?.toString() == _userUid;
  }

  void _ensureGroupManager(String? email) {
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    if (!_isEventGroupAdmin(normalizedEmail)) {
      throw Exception(
        'Only instructors and superadmins can manage event groups.',
      );
    }
  }

  String? _authEmailForUser(Map<String, dynamic> userData) {
    final email = userData['Email']?.toString().trim().toLowerCase() ?? '';
    final role =
        userData['Role']?.toString().toLowerCase().replaceAll(
          RegExp(r'[^a-z]'),
          '',
        ) ??
        '';
    const supportedRoles = {
      'teamlead',
      'mentor',
      'salesadmin',
      'instructor',
      'superadmin',
    };
    if (email.isEmpty || !supportedRoles.contains(role)) return null;
    return email.startsWith('${role}_') ? email : '${role}_$email';
  }

  bool _isEventGroupAdmin(String email) =>
      email.startsWith('superadmin_') || email.startsWith('instructor_');

  String _profileEmail(String email) {
    for (final role in [
      'teamlead',
      'mentor',
      'instructor',
      'superadmin',
      'salesadmin',
    ]) {
      final prefix = '${role}_';
      if (email.startsWith(prefix)) return email.substring(prefix.length);
    }
    return email;
  }

  @override
  Future<void> close() async {
    await _groupsSubscription?.cancel();
    return super.close();
  }
}
