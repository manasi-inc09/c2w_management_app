
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:equatable/equatable.dart';

abstract class DashBoardState extends Equatable {
  const DashBoardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before fetching has started
class DashBoardInitial extends DashBoardState {
  const DashBoardInitial();
}

/// Loading state while fetching enquiries from Firestore
class DashBoardLoading extends DashBoardState {
  const DashBoardLoading();
}

/// Success state with non-empty enquiries list
class DashBoardLoaded extends DashBoardState {
  final List<EnquiryModel> enquiries;

  const DashBoardLoaded(this.enquiries);

  @override
  List<Object?> get props => [enquiries];
}

/// State when no enquiries exist in Firestore collection
class DashBoardEmpty extends DashBoardState {
  const DashBoardEmpty();
}

/// State when fetching fails with an error message
class DashBoardError extends DashBoardState {
  final String message;

  const DashBoardError(this.message);

  @override
  List<Object?> get props => [message];
}
