import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EnquiryHistoryItem extends Equatable {
  final String id;
  final String studentName;
  final String mobileNo;
  final String collegeName;
  final List<String> interestedBatches;
  final String mode;
  final String studentFeedback;
  final String referenceBy;
  final String enquirySource;
  final String enquiryAddedBy;
  final String callStatus;
  final String admissionStatus;
  final DateTime? createdAt;

  const EnquiryHistoryItem({
    required this.id,
    required this.studentName,
    required this.mobileNo,
    required this.collegeName,
    required this.interestedBatches,
    required this.mode,
    required this.studentFeedback,
    required this.referenceBy,
    required this.enquirySource,
    this.enquiryAddedBy = '',
    required this.callStatus,
    required this.admissionStatus,
    this.createdAt,
  });

  factory EnquiryHistoryItem.fromMap(
    Map<String, dynamic> data, {
    String mobileNo = '',
    String collegeName = '',
  }) {
    return EnquiryHistoryItem(
      id: (data['History Id'] ?? '').toString(),
      studentName: (data['Student Name'] ?? '').toString(),
      mobileNo: (data['Mobile No'] ?? mobileNo).toString(),
      collegeName: (data['College Name'] ?? collegeName).toString(),
      interestedBatches: EnquiryModel.parseBatches(data['Interested Batch']),
      mode: (data['Mode'] ?? '').toString(),
      studentFeedback: (data['Student Feedback'] ?? '').toString(),
      referenceBy: (data['Reference By'] ?? '').toString(),
      enquirySource: (data['Enquiry Source'] ?? '').toString(),
      enquiryAddedBy: (data['enquiryAddedBy'] ?? '').toString(),
      callStatus: (data['Call Status'] ?? 'Pending').toString(),
      admissionStatus: EnquiryModel.parseAdmissionStatus(data),
      createdAt: EnquiryModel.parseDateTime(data['Created At']),
    );
  }

  String get formattedDate => createdAt == null
      ? 'N/A'
      : '${createdAt!.day.toString().padLeft(2, '0')} ${EnquiryModel.months[createdAt!.month - 1]} ${createdAt!.year}';

  String get interestedBatchDisplay => interestedBatches.isEmpty
      ? 'Interested for- Not specified'
      : 'Interested for- ${interestedBatches.join(', ')}';

  Map<String, dynamic> toMap() => {
    'History Id': id,
    'Student Name': studentName,
    'Interested Batch': interestedBatches,
    'Mode': mode,
    'Student Feedback': studentFeedback,
    'Reference By': referenceBy,
    'Enquiry Source': enquirySource,
    'enquiryAddedBy': enquiryAddedBy,
    'Call Status': callStatus,
    'Admission Status': admissionStatus,
    'Created At': createdAt == null ? null : Timestamp.fromDate(createdAt!),
  };

  @override
  List<Object?> get props => [
    id,
    studentName,
    mobileNo,
    collegeName,
    interestedBatches,
    mode,
    studentFeedback,
    referenceBy,
    enquirySource,
    enquiryAddedBy,
    callStatus,
    admissionStatus,
    createdAt,
  ];
}

class EnquiryModel extends Equatable {
  final String id;
  final String studentName;
  final String mobileNo;
  final String collegeName;
  final List<String> interestedBatches;
  final String mode;
  final String studentFeedback;
  final String referenceBy;
  final String enquirySource;
  final String enquiryAddedBy;
  final String callStatus;
  final String admissionStatus;
  final List<EnquiryHistoryItem> enquiryHistory;
  final DateTime? callStatusUpdatedAt;
  final DateTime? admissionStatusUpdatedAt;
  final DateTime? createdAt;

  static const callStatuses = ['Done', 'Pending', 'Not Recieved'];
  static const admissionStatuses = ['Not Yet', 'Completed'];

  bool get admissionCompleted => admissionStatus == 'Completed';

  const EnquiryModel({
    required this.id,
    required this.studentName,
    required this.mobileNo,
    required this.collegeName,
    required this.interestedBatches,
    required this.mode,
    required this.studentFeedback,
    required this.referenceBy,
    required this.enquirySource,
    this.enquiryAddedBy = '',
    this.callStatus = 'Pending',
    this.admissionStatus = 'Not Yet',
    this.enquiryHistory = const [],
    this.callStatusUpdatedAt,
    this.admissionStatusUpdatedAt,
    this.createdAt,
  });

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formatted date in "dd MMM yyyy" format (e.g., "16 Oct 2025")
  String get formattedDate {
    if (createdAt == null) return 'N/A';
    final day = createdAt!.day.toString().padLeft(2, '0');
    final month = months[createdAt!.month - 1];
    final year = createdAt!.year.toString();
    return '$day $month $year';
  }

  /// Formatted string for interested batches
  String get interestedBatchDisplay {
    if (interestedBatches.isEmpty) {
      return 'Interested for- Not specified';
    }
    return 'Interested for- ${interestedBatches.join(', ')}';
  }

  factory EnquiryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return EnquiryModel.fromMap(data, id: doc.id);
  }

  factory EnquiryModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return EnquiryModel(
      id: id ?? '',
      studentName: (data['Student Name'] ?? '').toString().trim(),
      mobileNo: (data['Mobile No'] ?? '').toString().trim(),
      collegeName: (data['College Name'] ?? '').toString().trim(),
      interestedBatches: _parseBatches(data['Interested Batch']),
      mode: (data['Mode'] ?? '').toString().trim(),
      studentFeedback: (data['Student Feedback'] ?? '').toString().trim(),
      referenceBy: (data['Reference By'] ?? '').toString().trim(),
      enquirySource: (data['Enquiry Source'] ?? '').toString().trim(),
      enquiryAddedBy: (data['enquiryAddedBy'] ?? '').toString().trim(),
      callStatus: _parseCallStatus(data['Call Status']),
      admissionStatus: _parseAdmissionStatus(data),
      enquiryHistory: _parseHistory(
        data['Enquiry History'],
        mobileNo: (data['Mobile No'] ?? '').toString(),
        collegeName: (data['College Name'] ?? '').toString(),
      ),
      callStatusUpdatedAt: _parseDateTime(data['Call Status Updated At']),
      admissionStatusUpdatedAt: _parseDateTime(
        data['Admission Status Updated At'],
      ),
      createdAt: _parseDateTime(data['Created At']),
    );
  }

  EnquiryModel copyWith({List<EnquiryHistoryItem>? enquiryHistory}) {
    return EnquiryModel(
      id: id,
      studentName: studentName,
      mobileNo: mobileNo,
      collegeName: collegeName,
      interestedBatches: interestedBatches,
      mode: mode,
      studentFeedback: studentFeedback,
      referenceBy: referenceBy,
      enquirySource: enquirySource,
      enquiryAddedBy: enquiryAddedBy,
      callStatus: callStatus,
      admissionStatus: admissionStatus,
      enquiryHistory: enquiryHistory ?? this.enquiryHistory,
      callStatusUpdatedAt: callStatusUpdatedAt,
      admissionStatusUpdatedAt: admissionStatusUpdatedAt,
      createdAt: createdAt,
    );
  }

  static String _parseAdmissionStatus(Map<String, dynamic> data) {
    final status = data['Admission Status']?.toString().trim();
    if (admissionStatuses.contains(status)) return status!;
    return data['Admission Completed'] == true ? 'Completed' : 'Not Yet';
  }

  static String parseAdmissionStatus(Map<String, dynamic> data) =>
      _parseAdmissionStatus(data);

  static List<EnquiryHistoryItem> _parseHistory(
    dynamic value, {
    String mobileNo = '',
    String collegeName = '',
  }) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (entry) =>
              EnquiryHistoryItem.fromMap(
                Map<String, dynamic>.from(entry),
                mobileNo: mobileNo,
                collegeName: collegeName,
              ),
        )
        .toList()
      ..sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });
  }

  static String _parseCallStatus(dynamic value) {
    final status = value?.toString().trim();
    if (status == 'Not Received') return 'Not Recieved';
    return callStatuses.contains(status) ? status! : 'Pending';
  }

  static List<String> _parseBatches(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return [];
      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [trimmed];
    }
    return [value.toString().trim()];
  }

  static List<String> parseBatches(dynamic value) => _parseBatches(value);

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime? parseDateTime(dynamic value) => _parseDateTime(value);

  Map<String, dynamic> toMap() {
    return {
      'Student Name': studentName,
      'Mobile No': mobileNo,
      'College Name': collegeName,
      'Interested Batch': interestedBatches,
      'Mode': mode,
      'Student Feedback': studentFeedback,
      'Reference By': referenceBy,
      'Enquiry Source': enquirySource,
      'enquiryAddedBy': enquiryAddedBy,
      'Call Status': callStatus,
      'Admission Status': admissionStatus,
      'Enquiry History': enquiryHistory.map((item) => item.toMap()).toList(),
      'Admission Completed': admissionCompleted,
      'Call Status Updated At': callStatusUpdatedAt != null
          ? Timestamp.fromDate(callStatusUpdatedAt!)
          : null,
      'Admission Status Updated At': admissionStatusUpdatedAt != null
          ? Timestamp.fromDate(admissionStatusUpdatedAt!)
          : null,
      'Created At': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  @override
  List<Object?> get props => [
    id,
    studentName,
    mobileNo,
    collegeName,
    interestedBatches,
    mode,
    studentFeedback,
    referenceBy,
    enquirySource,
    enquiryAddedBy,
    callStatus,
    admissionStatus,
    enquiryHistory,
    callStatusUpdatedAt,
    admissionStatusUpdatedAt,
    createdAt,
  ];
}
