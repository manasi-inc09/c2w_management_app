import 'package:c2w_management_app/features/enquiry/dashboard/domain/usecase/calling.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/data/repository/GetEnquiryData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EnquiryPersonProfile extends StatefulWidget {
  const EnquiryPersonProfile({super.key, this.enquiry});

  final EnquiryModel? enquiry;

  @override
  State<EnquiryPersonProfile> createState() => _EnquiryPersonProfileState();
}

class _EnquiryPersonProfileState extends State<EnquiryPersonProfile>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  bool isCollapsed = false;
  EnquiryModel? _activeEnquiry;

  EnquiryModel? get _enquiry => _activeEnquiry ?? widget.enquiry;

  static const double expandedHeight = 280;

  static const double bottomHeight = 92;

  static const bgColor = Color.fromRGBO(14, 16, 32, 1);
  static const appBarColor = Color.fromRGBO(20, 22, 39, 1);
  static const cardColor = Color.fromRGBO(22, 27, 46, 1);
  static const blue = Color.fromRGBO(43, 163, 232, 1);

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

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _scrollController.addListener(() {
      // how much the big header can shrink
      const collapseDistance = expandedHeight - kToolbarHeight - bottomHeight;

      // show the small title a little before it is fully closed
      final collapsed = _scrollController.offset > collapseDistance - 20;
      if (collapsed != isCollapsed) {
        setState(() => isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _callStatusColor(String status) {
    switch (status) {
      case 'Done':
        return const Color(0xFF19D18A);
      case 'Not Recieved':
        return const Color(0xFFFF5268);
      default:
        return const Color(0xFFFFB21A);
    }
  }

  Future<void> _saveEnquiryField(String field, dynamic value) async {
    final enquiry = _enquiry;
    if (enquiry == null || enquiry.id.isEmpty) return;
    try {
      final fields = <String, dynamic>{field: value};
      if (field == 'Call Status') {
        fields['Call Status Updated At'] = Timestamp.now();
      } else if (field == 'Admission Status') {
        fields['Admission Status Updated At'] = Timestamp.now();
        fields['Admission Completed'] = value == 'Completed';
      }
      await GetEnquiryData().updateEnquiryFields(
        enquiryId: enquiry.id,
        historyId: enquiry.enquiryHistory.isEmpty
            ? null
            : enquiry.enquiryHistory.last.id,
        fields: fields,
      );
      if (!mounted) return;
      context.read<DashBoardBloc>().add(const RefreshEnquiriesEvent());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update enquiry: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        if (state is DashBoardLoaded && state.enquiries.isNotEmpty) {
          _activeEnquiry = widget.enquiry == null
              ? state.enquiries.first
              : state.enquiries.firstWhere(
                  (item) => item.id == widget.enquiry!.id,
                  orElse: () => widget.enquiry!,
                );
        } else {
          _activeEnquiry ??= widget.enquiry;
        }
        if (_enquiry == null &&
            (state is DashBoardInitial || state is DashBoardLoading)) {
          return const Scaffold(
            backgroundColor: bgColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: bgColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: expandedHeight,
                backgroundColor: appBarColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                centerTitle: false,
                titleSpacing: 0,

                title: AnimatedOpacity(
                  opacity: isCollapsed ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _enquiry?.studentName ?? 'Enquiry details',
                        style: GoogleFonts.figtree(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_enquiry?.interestedBatchDisplay ?? 'Interested for- Not specified'} • ${_enquiry?.formattedDate ?? 'N/A'}',
                        style: GoogleFonts.figtree(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  AnimatedOpacity(
                    opacity: isCollapsed ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Center(
                      child: Text(
                        'Raised on: ${_enquiry?.formattedDate ?? 'N/A'}',
                        style: GoogleFonts.figtree(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: AnimatedOpacity(
                    opacity: isCollapsed ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: _bigHeader(context),
                  ),
                ),

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(bottomHeight),
                  child: _staticPart(),
                ),
              ),

              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: blue,
                  labelColor: blue,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: Colors.white12,
                  tabs: const [
                    Tab(text: "Details"),
                    Tab(text: "History"),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: _tabController.index == 0
                      ? _detailsTab()
                      : _historyTab(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _staticPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  'Call Status',
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),
                if (_enquiry?.callStatusUpdatedAt != null)
                  Text(
                    _formatStatusDate(_enquiry!.callStatusUpdatedAt!),
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                const SizedBox(width: 8),
                _statusDropdown(
                  value: _enquiry?.callStatus ?? 'Pending',
                  options: EnquiryModel.callStatuses,
                  onSelected: (status) =>
                      _saveEnquiryField('Call Status', status),
                  color: _callStatusColor(_enquiry?.callStatus ?? 'Pending'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  'Admission Status',
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const Spacer(),

                if (_enquiry?.admissionStatusUpdatedAt != null)
                  Text(
                    _formatStatusDate(_enquiry!.admissionStatusUpdatedAt!),
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),

                const SizedBox(width: 8),

                _statusDropdown(
                  value: _enquiry?.admissionStatus ?? 'Not Yet',
                  options: EnquiryModel.admissionStatuses,
                  onSelected: (status) {
                    _saveEnquiryField('Admission Status', status);
                  },
                  color: _enquiry?.admissionStatus == 'Cancel'
                      ? const Color(0xFFE53935) // Red
                      : _enquiry?.admissionStatus == 'Completed'
                      ? const Color(0xFF19D18A) // Green
                      : const Color(0xFFFFB21A), // Orange for Not Yet
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
    required Color color,
  }) {
    return PopupMenuButton<String>(
      initialValue: value,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map(
            (status) => PopupMenuItem<String>(
              value: status,
              child: Text(status, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 6, color: color),
            const SizedBox(width: 5),
            Text(value, style: GoogleFonts.figtree(fontSize: 11, color: color)),
            Icon(Icons.keyboard_arrow_down, size: 15, color: color),
          ],
        ),
      ),
    );
  }

  String _formatStatusDate(DateTime date) {
    const months = [
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Widget _bigHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        kToolbarHeight + MediaQuery.of(context).padding.top + 8,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 233, 186, 169),
                ),
                child: Center(
                  child: Text(
                    _enquiry?.studentName.isNotEmpty == true
                        ? _enquiry!.studentName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.figtree(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _enquiry?.studentName.isNotEmpty == true
                    ? _enquiry!.studentName
                    : 'Unnamed student',
                style: GoogleFonts.figtree(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                "Interested for",
                style: GoogleFonts.figtree(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromRGBO(42, 45, 62, 1),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _enquiry?.interestedBatches.isNotEmpty == true
                      ? _enquiry!.interestedBatches.join(', ')
                      : 'Not specified',
                  style: GoogleFonts.figtree(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsTab() {
    return Column(
      children: [
        _card("Contact Details", [
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white54),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  "Mobile No",
                  _enquiry?.mobileNo ?? 'Not specified',
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(25, 229, 122, 1),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  final phone = _enquiry?.mobileNo ?? '';
                  if (phone.isNotEmpty) makePhoneCall(phone);
                },
                child: const Text("Call"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field("Reference by", _enquiry?.referenceBy ?? 'Not specified'),
        ]),
        _card("User side", [
          _field("User feedback", _enquiry?.studentFeedback ?? 'Not specified'),
          const SizedBox(height: 12),
          _field("Enquiry source", _enquiry?.enquirySource ?? 'Not specified'),
          const SizedBox(height: 12),
          _field("Mode", _enquiry?.mode ?? 'Not specified'),
        ]),
        _card("Academic Details", [
          _field("College name", _enquiry?.collegeName ?? 'Not specified'),
          const SizedBox(height: 12),
          _field(
            "Interested batches",
            _enquiry?.interestedBatchDisplay ?? 'Not specified',
          ),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _historyTab() {
    final enquiryHistory = _enquiry?.enquiryHistory ?? const [];
    if (enquiryHistory.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            // decoration: BoxDecoration(),
            height: 230,
            width: 260,
            child: Image.asset("assets/images/sales_admin/nulllist.png"),
          ),
        ],
      );
    } else {
      final chronologicalHistory = enquiryHistory;
      return Column(
        children: [
          for (var index = 0; index < chronologicalHistory.length - 1; index++)
            _historyCard(
              title: '${_ordinal(index + 1)} Enquiry',
              item: chronologicalHistory[index],
            ),
          const SizedBox(height: 40),
        ],
      );
    }
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Widget _historyCard({
    required String title,
    required EnquiryHistoryItem item,
  }) {
    final isCompleted = item.admissionStatus.toLowerCase() == 'completed';
    final admissionColor = isCompleted
        ? const Color(0xFF13CE8B)
        : Colors.redAccent;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      padding: const EdgeInsets.fromLTRB(8, 8, 9, 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 17,
            margin: const EdgeInsets.only(top: 1, right: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6FD9B5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.formattedDate,
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                _historyRow(
                  'Interested for',
                  item.interestedBatches.join(', '),
                ),
                _historyDivider(),
                _historyRow(
                  'Admission status',
                  item.admissionStatus,
                  valueColor: admissionColor,
                  showDot: true,
                ),
                _historyDivider(),
                Text(
                  'User feedback',
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    item.studentFeedback.isEmpty
                        ? 'Not specified'
                        : item.studentFeedback,
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
    bool showDot = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(fontSize: 13, color: Colors.white54),
        ),
        const Spacer(),
        if (showDot) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: valueColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          value.isEmpty ? 'Not specified' : value,
          style: GoogleFonts.figtree(fontSize: 12, color: valueColor),
        ),
      ],
    );
  }

  Widget _historyDivider() =>
      const Divider(color: Colors.white10, height: 12, thickness: 0.5);

  Widget _card(String title, List<Widget> children, {String? date}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.figtree(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  date,
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.figtree(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
