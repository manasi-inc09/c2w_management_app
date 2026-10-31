import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ExpenseDeletionLogsEvent {}

class ExpenseDeletionLogsRequested extends ExpenseDeletionLogsEvent {}

class ExpenseDeletionLogsReceived extends ExpenseDeletionLogsEvent {
  final List<Map<String, dynamic>> logs;

  ExpenseDeletionLogsReceived(this.logs);
}

class ExpenseDeletionLogsFailed extends ExpenseDeletionLogsEvent {
  final String error;

  ExpenseDeletionLogsFailed(this.error);
}

class ExpenseDeletionLogsState {
  final List<Map<String, dynamic>> logs;
  final bool isLoading;
  final String? error;

  const ExpenseDeletionLogsState({
    this.logs = const [],
    this.isLoading = true,
    this.error,
  });
}

class ExpenseDeletionLogsBloc
    extends Bloc<ExpenseDeletionLogsEvent, ExpenseDeletionLogsState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  ExpenseDeletionLogsBloc({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const ExpenseDeletionLogsState()) {
    on<ExpenseDeletionLogsRequested>(_onRequested);
    on<ExpenseDeletionLogsReceived>((event, emit) {
      emit(ExpenseDeletionLogsState(logs: event.logs, isLoading: false));
    });
    on<ExpenseDeletionLogsFailed>((event, emit) {
      emit(ExpenseDeletionLogsState(isLoading: false, error: event.error));
    });
  }

  Future<void> _onRequested(
    ExpenseDeletionLogsRequested event,
    Emitter<ExpenseDeletionLogsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _firestore
        .collection('expenseDeletionLogs')
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            add(
              ExpenseDeletionLogsReceived(
                snapshot.docs
                    .map(
                      (document) => <String, dynamic>{
                        ...document.data(),
                        'id': document.id,
                      },
                    )
                    .toList(),
              ),
            );
          },
          onError: (Object error) {
            add(ExpenseDeletionLogsFailed('$error'));
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
