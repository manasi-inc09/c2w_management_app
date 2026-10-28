import 'dart:developer';
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetEnquiryData {
  final FirebaseFirestore _firestore;

  GetEnquiryData({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<EnquiryModel>> fetchEnquiries() async {
    try {
      final email = (FirebaseAuth.instance.currentUser?.email ??
              AuthRepository.authEmail ??
              '')
          .trim()
          .toLowerCase();
      final isSalesAdminOrSuperAdmin =
          email.contains('salesadmin_') || email.contains('superadmin_');
      final isTeamLeadMentorOrInstructor =
          email.startsWith('teamlead_') ||
          email.startsWith('mentor_') ||
          email.startsWith('instructor_');
      final snapshot = await _firestore.collection('Enquiries').get();
      final enquiries = <EnquiryModel>[];
      for (final doc in snapshot.docs) {
        final parent = doc.data();
        if (parent['Is Historical'] == true &&
            !isSalesAdminOrSuperAdmin &&
            !isTeamLeadMentorOrInstructor) {
          continue;
        }

        final history = parent['Enquiry History'];
        if (history is List && history.isNotEmpty) {
          final entries = history.whereType<Map>().map((value) {
            final item = Map<String, dynamic>.from(value);
            item['Mobile No'] ??= parent['Mobile No'];
            item['College Name'] ??= parent['College Name'];
            return item;
          }).where((item) {
            if (isSalesAdminOrSuperAdmin) return true;
            if (email.isEmpty) return false;
            return (item['enquiryAddedBy'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase() ==
                email;
          }).toList();
          if (entries.isEmpty) continue;

          // Team leads, mentors, and instructors get one card per enquiry
          // they personally created, including older entries in the history.
          if (isTeamLeadMentorOrInstructor) {
            for (final entry in entries) {
              enquiries.add(
                EnquiryModel.fromMap({
                  ...entry,
                  'Enquiry History': entries,
                }, id: doc.id),
              );
            }
            continue;
          }

          final latest = Map<String, dynamic>.from(entries.last)
            ..['Mobile No'] = parent['Mobile No']
            ..['College Name'] = parent['College Name'];
          enquiries.add(
            EnquiryModel.fromMap({
              ...latest,
              'Enquiry History': entries,
            }, id: doc.id),
          );
          continue;
        }

        // Keep older documents visible until they are migrated on next entry.
        if (!isSalesAdminOrSuperAdmin &&
            (email.isEmpty ||
                (parent['enquiryAddedBy'] ?? '')
                        .toString()
                        .trim()
                        .toLowerCase() !=
                    email)) {
          continue;
        }
        enquiries.add(EnquiryModel.fromFirestore(doc));
      }
      enquiries.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      log('Successfully fetched ${enquiries.length} enquiries');
      return enquiries;
    } catch (e, stackTrace) {
      log('Error fetching enquiries from Firestore: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateEnquiryField({
    required String enquiryId,
    required String field,
    required dynamic value,
  }) => updateEnquiryFields(enquiryId: enquiryId, fields: {field: value});

  Future<void> updateEnquiryFields({
    required String enquiryId,
    String? historyId,
    required Map<String, dynamic> fields,
  }) async {
    final reference = _firestore.collection('Enquiries').doc(enquiryId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data() ?? {};
      final history = (data['Enquiry History'] as List? ?? [])
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
      if (history.isEmpty) {
        transaction.update(reference, fields);
        return;
      }
      final targetIndex = historyId == null
          ? history.length - 1
          : history.lastIndexWhere(
              (entry) => entry['History Id']?.toString() == historyId,
            );
      if (targetIndex < 0) {
        throw StateError('Enquiry history item was not found.');
      }
      history[targetIndex].addAll(fields);
      transaction.update(reference, {'Enquiry History': history});
    });
  }
}
