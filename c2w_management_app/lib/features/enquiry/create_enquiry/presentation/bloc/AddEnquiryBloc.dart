import 'package:c2w_management_app/features/enquiry/create_enquiry/data/repository/AddEnquiry.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryEvent.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEnquiryBloc extends Bloc<AddEnquiryEvent, AddEnquiryState> {
  final AddEnquiryRepository repository;

  AddEnquiryBloc({required this.repository}) : super(AddEnquiryInitial()) {
    on<CreateEnquiryEvent>(_onCreateEnquiry);
  }

  Future<void> _onCreateEnquiry(
    CreateEnquiryEvent event,
    Emitter<AddEnquiryState> emit,
  ) async {
    emit(AddEnquiryLoading());

    try {
      final wasRepeatEnquiry = await repository.createEnquiry(
        studentName: event.studentName,
        mobileNo: event.mobileNo,
        collegeName: event.collegeName,
        interestedBatches: event.interestedBatches,
        mode: event.mode,
        studentFeedback: event.studentFeedback,
        referenceBy: event.referenceBy,
        enquirySource: event.enquirySource,
        enquiryAddedBy: event.enquiryAddedBy,
        enquiryType: event.enquiryType
      );

      emit(AddEnquirySuccess(wasRepeatEnquiry: wasRepeatEnquiry));
    } catch (e) {
      emit(AddEnquiryFailure('Failed to create enquiry. Please try again.'));
    }
  }
}
