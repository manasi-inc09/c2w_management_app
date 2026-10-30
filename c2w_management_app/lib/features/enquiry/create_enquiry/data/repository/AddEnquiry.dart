import 'package:cloud_firestore/cloud_firestore.dart';

class AddEnquiryRepository {
  final FirebaseFirestore firestore;

  AddEnquiryRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, String>>> findEnquiriesByMobilePrefix(
    String prefix,
  ) async {
    final normalizedPrefix = _normalizeMobile(prefix);
    if (normalizedPrefix.length < 4) return const [];

    final docs = (await firestore.collection('Enquiries').get()).docs;
    final matchesByMobile = <String, Map<String, String>>{};
    final datesByMobile = <String, DateTime>{};

    for (final doc in docs) {
      final data = doc.data();
      final history = data['Enquiry History'];
      final entries = <Map<String, dynamic>>[];
      if (history is List) {
        entries.addAll(
          history.whereType<Map>().map((value) => Map<String, dynamic>.from(value)),
        );
      }
      // Also search legacy documents that store the enquiry fields at the root.
      if (data['Student Name'] != null || entries.isEmpty) entries.add(data);

      for (final entry in entries) {
        final mobileNo = (entry['Mobile No'] ?? data['Mobile No'] ?? '')
            .toString();
        final normalizedMobile = _normalizeMobile(mobileNo);
        if (!normalizedMobile.startsWith(normalizedPrefix)) {
          continue;
        }

        final date = _dateFrom(entry['Created At']);
        final existingDate = datesByMobile[normalizedMobile];
        if (existingDate != null && !date.isAfter(existingDate)) continue;
        datesByMobile[normalizedMobile] = date;
        matchesByMobile[normalizedMobile] = {
          'mobileNo': mobileNo,
          'studentName': (entry['Student Name'] ?? '').toString(),
          'collegeName': (entry['College Name'] ?? data['College Name'] ?? '')
              .toString(),
          'referenceBy': (entry['Reference By'] ?? '').toString(),
          'enquirySource': (entry['Enquiry Source'] ?? '').toString(),
        };
      }
    }

    final matches = matchesByMobile.values.toList()
      ..sort((a, b) => a['mobileNo']!.compareTo(b['mobileNo']!));
    return matches;
  }

  Future<bool> createEnquiry({
    required String studentName,
    required String mobileNo,
    required String collegeName,
    required String academicYear,
    required String branch,
    required List<String> interestedBatches,
    required String mode,
    required String studentFeedback,
    required String referenceBy,
    required String enquirySource,
    required String enquiryAddedBy,
    required String enquiryType,              /// for dashboard only (i.e General)
  }) async {
    final collection = firestore.collection('Enquiries');
    final docs = (await collection.get()).docs.where((doc) {
      final data = doc.data();
      return _normalizeMobile((data['Mobile No'] ?? '').toString()) ==
              _normalizeMobile(mobileNo) &&
          _normalizeText((data['College Name'] ?? '').toString()) ==
              _normalizeText(collegeName);
    }).toList();

    final now = Timestamp.now();
    final entry = <String, dynamic>{
      'History Id': '',
      'Student Name': studentName,
      'Academic Year': academicYear,
      'Branch': branch,
      'Interested Batch': interestedBatches,
      'Mode': mode,
      'Student Feedback': studentFeedback,
      'Reference By': referenceBy,
      'Enquiry Source': enquirySource,
      'Created At': now,
      'Call Status': 'Pending',
      'Admission Status': 'Not Yet',
      'Admission Completed': false,
      'Call Status Updated At': null,
      'Admission Status Updated At': null,
      'enquiryAddedBy': enquiryAddedBy,
      'Enquiry Type':enquiryType
    };

    if (docs.isEmpty) {
      final ref = collection.doc();
      entry['History Id'] = ref.id;
      await ref.set({
        'Mobile No': mobileNo,
        'College Name': collegeName,
        'Enquiry History': [entry],
      });
      return false;
    }

    docs.sort((a, b) => _latestDate(b.data()).compareTo(_latestDate(a.data())));
    final target = docs.first;
    final history = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final doc in docs) {
      final data = doc.data();
      final previousHistory = data['Enquiry History'];
      if (previousHistory is List) {
        for (final value in previousHistory.whereType<Map>()) {
          final item = _normalizeHistory(Map<String, dynamic>.from(value));
          final id = (item['History Id'] ?? '').toString();
          if (id.isEmpty || seen.add(id)) history.add(item);
        }
      }
      // Migrate the old one-enquiry-per-document format into the same array.
      if (data['Student Name'] != null) {
        final legacyEntry = _normalizeHistory({
          ...data,
          'History Id':
              '${doc.id}_${_latestDate(data).millisecondsSinceEpoch}',
        });
        final id = legacyEntry['History Id'].toString();
        if (seen.add(id)) history.add(legacyEntry);
      }
    }

    history.sort((a, b) => _dateFrom(a['Created At']).compareTo(
      _dateFrom(b['Created At']),
    ));
    entry['History Id'] = '${target.id}_${now.millisecondsSinceEpoch}';
    history.add(entry);

    final batch = firestore.batch();
    batch.set(target.reference, {
      'Mobile No': mobileNo,
      'College Name': collegeName,
      'Enquiry History': history,
    });
    for (final duplicate in docs.skip(1)) {
      batch.delete(duplicate.reference);
    }
    await batch.commit();
    return true;
  }

  Map<String, dynamic> _normalizeHistory(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data)
      ..remove('Mobile No')
      ..remove('College Name')
      ..remove('Is Historical')
      ..remove('Previously Contacted')
      ..remove('Enquiry History');
    normalized['Interested Batch'] ??= <String>[];
    normalized['Call Status'] ??= 'Pending';
    normalized['Admission Status'] ??=
        normalized['Admission Completed'] == true ? 'Completed' : 'Not Yet';
    return normalized;
  }

  String _normalizeMobile(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  String _normalizeText(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  DateTime _latestDate(Map<String, dynamic> data) {
    final history = data['Enquiry History'];
    if (history is List && history.isNotEmpty && history.last is Map) {
      return _dateFrom((history.last as Map)['Created At']);
    }
    return _dateFrom(data['Created At']);
  }

  DateTime _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
    return DateTime(1970);
  }
}
