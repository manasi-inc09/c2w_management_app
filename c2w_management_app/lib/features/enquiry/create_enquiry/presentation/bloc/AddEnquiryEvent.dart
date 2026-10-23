abstract class AddEnquiryEvent {}

class CreateEnquiryEvent extends AddEnquiryEvent {
  final String studentName;
  final String mobileNo;
  final String collegeName;
  final List<String> interestedBatches;
  final String mode;
  final String studentFeedback;
  final String referenceBy;
  final String enquirySource;
  final String enquiryAddedBy;
  final String enquiryType;

  CreateEnquiryEvent({
    required this.studentName,
    required this.mobileNo,
    required this.collegeName,
    required this.interestedBatches,
    required this.mode,
    required this.studentFeedback,
    required this.referenceBy,
    required this.enquirySource,
    required this.enquiryAddedBy,
    required this.enquiryType,
  });
}
