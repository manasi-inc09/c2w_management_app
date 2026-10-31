import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_person_profile.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/widgets/filters.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class Enquiry extends StatefulWidget {
  final String? collectionName;

  const Enquiry({super.key, this.collectionName});

  @override
  State<Enquiry> createState() => _EnquiryState();
}

class _EnquiryState extends State<Enquiry> {
  Map<String, String?> appliedFilters = {};
  bool isSearchVisible = false;
  String searchQuery = '';

  bool get _canOpenEnquiryDetails {
    final email = (AuthRepository.authEmail ?? '').trim().toLowerCase();
    return email.contains('superadmin_') || email.contains('salesadmin_');
  }

  Color _callStatusColor(String status) {
    switch (status) {
      case 'Done':
        return const Color.fromARGB(255, 64, 163, 59);

      case 'Not Recieved':
        return const Color(0xFFFF5268);

      default:
        return const Color(0xFFFFB21A);
    }
  }

  bool _sameStatus(String first, String second) =>
      first.toLowerCase().replaceAll('recieved', 'received') ==
      second.toLowerCase().replaceAll('recieved', 'received');

  Future<void> _refreshEnquiries() async {
    final bloc = context.read<DashBoardBloc>();
    final refreshFinished = bloc.stream.firstWhere(
      (state) =>
          state is DashBoardLoaded ||
          state is DashBoardEmpty ||
          state is DashBoardError,
    );
    bloc.add(const RefreshEnquiriesEvent());
    await refreshFinished;
  }

  Widget _scrollableMessage(Widget message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [SizedBox(height: 280, child: Center(child: message))],
    );
  }

  bool _authorHasRole(String authorEmail, String role) =>
      authorEmail.trim().toLowerCase().startsWith('${role.toLowerCase()}_');

  List<EnquiryModel> _visibleEnquiries(List<EnquiryModel> enquiries) {
    final query = searchQuery.toLowerCase().trim();
    return enquiries.where((item) {
      final matchesCollection =
          widget.collectionName == null ||
          item.collectionName == widget.collectionName;
      final matchesQuery =
          query.isEmpty ||
          item.studentName.toLowerCase().contains(query) ||
          item.mobileNo.toLowerCase().contains(query) ||
          item.collegeName.toLowerCase().contains(query) ||
          item.mode.toLowerCase().contains(query) ||
          item.callStatus.toLowerCase().contains(query) ||
          item.interestedBatchDisplay.toLowerCase().contains(query) ||
          item.formattedDate.toLowerCase().contains(query);
      final interest = appliedFilters['Interested for'];
      final callStatus =
          appliedFilters['Call Status'] ?? appliedFilters['Call status'];
      final raisedOn = appliedFilters['Raised on'];
      final admissionStatus = appliedFilters['Admission Status'];
      final enquirySource = appliedFilters['Enquiry Source'];
      final enquiryAddedBy = appliedFilters['Enquiry Taken By'];
      final history = item.enquiryHistory;
      final matchesInterest =
          interest == null ||
          item.interestedBatches.any((batch) =>
                  batch.toLowerCase().contains(interest.toLowerCase())) ||
          history.any((entry) => entry.interestedBatches.any((batch) =>
              batch.toLowerCase().contains(interest.toLowerCase())));
      final matchesStatus =
          callStatus == null ||
          _sameStatus(item.callStatus, callStatus) ||
          history.any((entry) => _sameStatus(entry.callStatus, callStatus));
      final matchesAdmissionStatus = admissionStatus == null ||
          item.admissionStatus.toLowerCase() == admissionStatus.toLowerCase() ||
          history.any((entry) =>
              entry.admissionStatus.toLowerCase() ==
              admissionStatus.toLowerCase());
      final matchesSource = enquirySource == null ||
          item.enquirySource.toLowerCase() == enquirySource.toLowerCase() ||
          history.any((entry) =>
              entry.enquirySource.toLowerCase() == enquirySource.toLowerCase());
      final matchesAddedBy = enquiryAddedBy == null ||
          _authorHasRole(item.enquiryAddedBy, enquiryAddedBy) ||
          history.any((entry) =>
              _authorHasRole(entry.enquiryAddedBy, enquiryAddedBy));
      bool dateMatches(DateTime? createdAt) {
        if (raisedOn == null) return true;
        if (createdAt == null) {
          return false;
        }
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
        switch (raisedOn) {
          case 'Today':
            return date == today;
          case 'Yesterday':
            return date == today.subtract(const Duration(days: 1));
          case 'Last 7 days':
            return !date.isBefore(today.subtract(const Duration(days: 6))) &&
                !date.isAfter(today);
          default:
            return true;
        }
      }

      final matchesDate = dateMatches(item.createdAt) ||
          history.any((entry) => dateMatches(entry.createdAt));
      return matchesCollection &&
          matchesQuery &&
          matchesInterest &&
          matchesStatus &&
          matchesAdmissionStatus &&
          matchesSource &&
          matchesAddedBy &&
          matchesDate;
    }).toList();
  }

  Widget _enquiriesList() {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        if (state is DashBoardLoading || state is DashBoardInitial) {
          return _scrollableMessage(
            const CircularProgressIndicator(color: Colors.white),
          );
        }
        if (state is DashBoardError) {
          return _scrollableMessage(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () => context.read<DashBoardBloc>().add(
                    const FetchEnquiriesEvent(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final all = state is DashBoardLoaded
            ? state.enquiries
            : <EnquiryModel>[];
        final collectionEnquiries = widget.collectionName == null
            ? all
            : all
                  .where(
                    (item) => item.collectionName == widget.collectionName,
                  )
                  .toList();
        final visible = _visibleEnquiries(all);
        if (visible.isEmpty) {
          if (collectionEnquiries.isEmpty) {
            return _scrollableMessage(
              const Text(
                'No enquiries found.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return _scrollableMessage(
            const Text(
              'No matching enquiries',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: visible.length,
          itemBuilder: (context, index) {
            final item = visible[index];
            final statusColor = _callStatusColor(item.callStatus);
            return Card(
              color: const Color(0xFF161B2E),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _canOpenEnquiryDetails
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EnquiryPersonProfile(enquiry: item),
                        ),
                      )
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.sizeOf(context).width < 380 ? 10 : 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 54,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.formattedDate,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: 'Call status: ${item.callStatus}',
                                  child: Icon(
                                    Icons.chat_bubble,
                                    color: item.callStatus
                                                .trim()
                                                .toLowerCase() ==
                                            'done'
                                        ? const Color.fromARGB(255, 207, 85, 85)
                                        : Colors.white30,
                                    size: 15,
                                  ),
                                ),
                                SizedBox(width: 3,),
                                Tooltip(
                                  message:
                                      'Admission status: ${item.admissionStatus}',
                                  child: Icon(
                                    Icons.check_circle,
                                    color: item.admissionStatus
                                                .trim()
                                                .toLowerCase() ==
                                            'completed'
                                        ? const Color(0xFF19D18A)
                                        : Colors.white30,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.studentName.isEmpty
                                  ? 'Unnamed student'
                                  : item.studentName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.interestedBatchDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              '• ${item.callStatus}',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.mobileNo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<DashBoardBloc>();
      if (bloc.state is DashBoardInitial) {
        bloc.add(const FetchEnquiriesEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final horizontalPadding = isCompact ? 8.0 : 12.0;
    Widget searchBar = const SizedBox();

    if (isSearchVisible) {
      searchBar = Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search enquiries...',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search, color: Colors.white54),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141627),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Enquiry Overview',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh enquiries',
            onPressed: () => context.read<DashBoardBloc>().add(
              const RefreshEnquiriesEvent(),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(color: Colors.white24),
            ),

            child: IconButton(
              onPressed: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;

                  if (!isSearchVisible) {
                    searchQuery = '';
                  }
                });
              },
              icon: Icon(
                isSearchVisible ? Icons.close : Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isCompact ? 50 : 56),
          child: SizedBox(
            height: isCompact ? 50 : 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              children: [
                Center(
                  child: Badge(
                    isLabelVisible: appliedFilters.values
                        .where((value) => value != null && value.isNotEmpty)
                        .isNotEmpty,
                    label: Text(
                      '${appliedFilters.values.where((value) => value != null && value.isNotEmpty).length}',
                    ),
                    backgroundColor: const Color.fromRGBO(5, 164, 255, 1),
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: () async {
                        final result = await showFilterSheet(
                          context,
                          initialFilters: appliedFilters,
                        );

                        if (result != null) {
                          setState(() {
                            appliedFilters = result; // page rebuilds after this
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                for (final label in [
                  'Call status',
                  'Interested for',
                  'Raised on',
                ])
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: isCompact ? 12 : 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: BlocBuilder<DashBoardBloc, DashBoardState>(
              builder: (context, state) {
                final loadedEnquiries = state is DashBoardLoaded
                    ? state.enquiries
                    : null;
                final count = loadedEnquiries != null
                    ? '${widget.collectionName == null ? loadedEnquiries.length : loadedEnquiries.where((item) => item.collectionName == widget.collectionName).length}'
                    : state is DashBoardEmpty
                    ? '0'
                    : null;
                return Text(
                  count == null ? 'Loading enquiries...' : '$count enquiries',
                  style: GoogleFonts.figtree(fontSize: 13, color: Colors.white),
                );
              },
            ),
          ),
          searchBar,

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshEnquiries,
              color: const Color.fromRGBO(5, 164, 255, 1),
              child: _enquiriesList(),
            ),
          ),
        ],
      ),
    );
  }
}
