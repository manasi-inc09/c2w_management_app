import 'package:equatable/equatable.dart';

abstract class DashBoardEvent extends Equatable {
  const DashBoardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the dashboard opens or when enquiries should be fetched
class FetchEnquiriesEvent extends DashBoardEvent {
  const FetchEnquiriesEvent();
}

/// Triggered when user pulls to refresh or manually refreshes enquiry list
class RefreshEnquiriesEvent extends DashBoardEvent {
  const RefreshEnquiriesEvent();
}
