abstract class AddEnquiryState {}

class AddEnquiryInitial extends AddEnquiryState {}

class AddEnquiryLoading extends AddEnquiryState {}

class AddEnquirySuccess extends AddEnquiryState {
  final bool wasRepeatEnquiry;

  AddEnquirySuccess({this.wasRepeatEnquiry = false});
}

class AddEnquiryFailure extends AddEnquiryState {
  final String message;

  AddEnquiryFailure(this.message);
}
