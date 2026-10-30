
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_person_profile.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EnquiryList extends StatefulWidget {
  const EnquiryList({
    super.key,
    this.searchQuery = '',
    this.filters = const {},
  });

  final String searchQuery;
  final Map<String, String?> filters;

  @override
  State<EnquiryList> createState() => _EnquiryListState();
}

class _EnquiryListState extends State<EnquiryList> {
  bool get _canOpenEnquiryDetails {
    final email = (AuthRepository.authEmail ?? '').trim().toLowerCase();
    return email.contains('superadmin_') || email.contains('salesadmin_');
  }

  Color _modeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return const Color.fromRGBO(5, 164, 255, 1);
      case 'virtual':
        return Colors.orange;
      default:
        return const Color.fromRGBO(5, 164, 255, 1);
    }
  }

  List<EnquiryModel> _filterEnquiries(List<EnquiryModel> list) {
  final query = widget.searchQuery.toLowerCase().trim();
  final filters = widget.filters;

  return list.where((item) {
    // Search
    final matchesSearch = query.isEmpty ||
        item.studentName.toLowerCase().contains(query) ||
        item.interestedBatchDisplay.toLowerCase().contains(query) ||
        item.mode.toLowerCase().contains(query) ||
        item.mobileNo.toLowerCase().contains(query) ||
        item.formattedDate.toLowerCase().contains(query) ||
        item.collegeName.toLowerCase().contains(query);

    // Interested batch
    final interestFilter = filters['Interested for'];
    final matchesInterest = interestFilter == null ||
        item.interestedBatches.any(
          (batch) => batch.toLowerCase().contains(
                interestFilter.toLowerCase(),
              ),
        );

    final statusFilter =
        filters['Call Status'] ?? filters['Call status'];

    final matchesMode = statusFilter == null ||
        item.mode.toLowerCase() == statusFilter.toLowerCase();

    // Enquiry source
    final sourceFilter = filters['Enquiry Source'];
    final matchesSource = sourceFilter == null ||
        item.enquirySource.toLowerCase() ==
            sourceFilter.toLowerCase();

    // Raised-on date
    final raisedOnFilter = filters['Raised on'];
    bool matchesRaisedOn = true;

    if (raisedOnFilter != null && item.createdAt != null) {
      final now = DateTime.now();
      final created = item.createdAt!;

      final today = DateTime(now.year, now.month, now.day);
      final enquiryDate =
          DateTime(created.year, created.month, created.day);

      switch (raisedOnFilter) {
        case 'Today':
          matchesRaisedOn = enquiryDate == today;
          break;
        case 'Yesterday':
          matchesRaisedOn =
              enquiryDate == today.subtract(const Duration(days: 1));
          break;
        case 'Last 7 days':
          matchesRaisedOn =
              !enquiryDate.isBefore(today.subtract(const Duration(days: 6))) &&
              !enquiryDate.isAfter(today);
          break;
      }
    } else if (raisedOnFilter != null && item.createdAt == null) {
      matchesRaisedOn = false;
    }

    return matchesSearch &&
        matchesInterest &&
        matchesMode &&
        matchesSource &&
        matchesRaisedOn;
  }).toList();
}

  Widget _buildCard(BuildContext context, EnquiryModel item) {
    final modeColor = _modeColor(item.mode);
    final displayName = item.studentName.isNotEmpty
        ? item.studentName.toUpperCase()
        : 'UNNAMED STUDENT';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF161B2E),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _canOpenEnquiryDetails
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EnquiryPersonProfile(enquiry: item),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(width: 3, height: 50, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.formattedDate,
                            style: GoogleFonts.figtree(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white24,
                          ),
                          const SizedBox(width: 8),
                          if (item.studentFeedback.isNotEmpty)
                            const Icon(
                              Icons.chat_bubble,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                          if (item.mode.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.interestedBatchDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.mode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: modeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '• ${item.mode}',
                          style: GoogleFonts.figtree(
                            color: modeColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      item.mobileNo.isNotEmpty ? item.mobileNo : 'N/A',
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsumer(BuildContext context) {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        if (state is DashBoardLoading || state is DashBoardInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(110, 75, 239, 1),
              ),
            ),
          );
        }

        if (state is DashBoardError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.figtree(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashBoardBloc>().add(
                            const FetchEnquiriesEvent(),
                          );
                    },
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Retry',
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161B2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final allEnquiries = state is DashBoardLoaded
            ? state.enquiries
            : <EnquiryModel>[];
        final filteredEnquiries = _filterEnquiries(allEnquiries);

        if (filteredEnquiries.isEmpty) {
          if (allEnquiries.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No matching enquiries',
                style: GoogleFonts.figtree(color: Colors.white54, fontSize: 14),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: filteredEnquiries.length,
          itemBuilder: (context, index) {
            final item = filteredEnquiries[index];
            return _buildCard(context, item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      context.read<DashBoardBloc>();
      return _buildConsumer(context);
    } catch (_) {
      return BlocProvider<DashBoardBloc>(
        create: (context) => DashBoardBloc()..add(const FetchEnquiriesEvent()),
        child: Builder(
          builder: (ctx) => _buildConsumer(ctx),
        ),
      );
    }
  }
}
