import 'dart:async';
import 'dart:developer';

import 'package:c2w_management_app/features/enquiry/dashboard/data/repository/GetEnquiryData.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashBoardBloc extends Bloc<DashBoardEvent, DashBoardState> {
  static const _loadTimeout = Duration(seconds: 15);
  final GetEnquiryData repository;

  DashBoardBloc({GetEnquiryData? repository})
      : repository = repository ?? GetEnquiryData(),
        super(const DashBoardInitial()) {
    on<FetchEnquiriesEvent>(_onFetchEnquiries);
    on<RefreshEnquiriesEvent>(_onRefreshEnquiries);
  }

  Future<void> _onFetchEnquiries(
    FetchEnquiriesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final loadStartedAt = DateTime.now();
    emit(const DashBoardLoading());
    try {
      final enquiries = await repository.fetchEnquiries().timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException(
          'Enquiry loading timed out after 15 seconds.',
        ),
      );
      if (enquiries.isEmpty) {
        await _waitOutEmptyResultLoader(loadStartedAt);
        if (emit.isDone) return;
        emit(const DashBoardEmpty());
      } else {
        emit(DashBoardLoaded(enquiries));
      }
    } catch (e) {
      log('DashBoardBloc: Failed to fetch enquiries: $e');
      emit(DashBoardError('Failed to fetch enquiries: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshEnquiries(
    RefreshEnquiriesEvent event,
    Emitter<DashBoardState> emit,
  ) async {
    final loadStartedAt = DateTime.now();
    emit(const DashBoardLoading());
    try {
      final enquiries = await repository.fetchEnquiries().timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException(
          'Enquiry refresh timed out after 15 seconds.',
        ),
      );
      if (enquiries.isEmpty) {
        await _waitOutEmptyResultLoader(loadStartedAt);
        if (emit.isDone) return;
        emit(const DashBoardEmpty());
      } else {
        emit(DashBoardLoaded(enquiries));
      }
    } catch (e) {
      log('DashBoardBloc: Failed to refresh enquiries: $e');
      emit(DashBoardError('Failed to refresh enquiries: ${e.toString()}'));
    }
  }

  Future<void> _waitOutEmptyResultLoader(DateTime loadStartedAt) async {
    final remaining = _loadTimeout - DateTime.now().difference(loadStartedAt);
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }
}

/// Typedef matching the file name 'DashBoardBoc.dart' for backwards compatibility
typedef DashBoardBoc = DashBoardBloc;
