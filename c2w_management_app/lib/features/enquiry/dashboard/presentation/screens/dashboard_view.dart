import 'dart:developer';

import 'package:c2w_management_app/core/commom_bottom_navigationbar.dart';
import 'package:c2w_management_app/features/Profile/presentation/screens/profile.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/screens/create_equiry.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_overview.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_person_profile.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/expense_manager.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/complete_profile_screen.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    try {
      context.read<DashBoardBloc>();
      return const _DashboardViewContent();
    } catch (_) {
      return BlocProvider<DashBoardBloc>(
        create: (context) => DashBoardBloc(),
        child: const _DashboardViewContent(),
      );
    }
  }
}

class _DashboardViewContent extends StatefulWidget {
  const _DashboardViewContent();

  @override
  State<_DashboardViewContent> createState() => _DashboardViewContentState();
}

class _DashboardViewContentState extends State<_DashboardViewContent> {
  // Index of the selected bottom navigation tab (0 = Home, 1 = Expenses)
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _ensureProfileComplete();
    final bloc = context.read<DashBoardBloc>();
    bloc.add(const FetchEnquiriesEvent());
  }

  Future<void> _ensureProfileComplete() async {
    final isComplete = await AuthRepository.isProfileComplete();
    if (!mounted || isComplete) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      (route) => false,
    );
  }

  /// Null-safe access to the logged in email (avoids `authEmail!` crashes).
  String get _email => AuthRepository.authEmail ?? '';

  /// Sales admin has no bottom navigation bar.
  bool get _isSalesAdmin => _email.contains("salesadmin_");

  bool get _isTeamLeadMentorOrInstructor =>
      _email.startsWith('teamlead_') ||
      _email.startsWith('mentor_') ||
      _email.startsWith('instructor_');

  /// These roles can open their own date-sorted enquiry list and history.
  bool get _canOpenEnquiryOverview =>
      _isTeamLeadMentorOrInstructor ||
      _email.contains('salesadmin_') ||
      _email.contains('superadmin_');

  /// Instructor / super admin get the ExpenseManager, everyone else gets
  /// their own IndividualExpenses screen.
  bool get _isExpenseManagerRole =>
      _email.contains("instructor") || _email.contains("superadmin");

  bool get _canViewUsers =>
      _email.startsWith('instructor_') || _email.startsWith('superadmin_');

  Future<void> _refreshEnquiries(BuildContext context) async {
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

  Color _modeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return const Color.fromRGBO(5, 164, 255, 1);
      case 'recorded':
        return Colors.orange;
      default:
        return const Color.fromRGBO(5, 164, 255, 1);
    }
  }

  Widget _buildEnquiriesList(BuildContext context, DashBoardState state) {
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
                style: GoogleFonts.figtree(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DashBoardBloc>().add(
                    const FetchEnquiriesEvent(),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: Text(
                  'Retry',
                  style: GoogleFonts.figtree(color: Colors.white, fontSize: 13),
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

    if (state is DashBoardEmpty ||
        (state is DashBoardLoaded && state.enquiries.isEmpty)) {
      return const SizedBox.shrink();
    }

    if (state is DashBoardLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.enquiries.length,
        itemBuilder: (context, index) {
          final item = state.enquiries[index];
          return _buildEnquiryCard(context, item);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEnquiryCard(BuildContext context, EnquiryModel item) {
    final isCompact = MediaQuery.sizeOf(context).width < 380;
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
          onTap: () {
            log(AuthRepository.authEmail!);
            if (_canOpenEnquiryOverview) {
              log("in card..");

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EnquiryPersonProfile(enquiry: item),
                ),
              );
            }
          },
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
                          Tooltip(
                            message: 'Call status: ${item.callStatus}',
                            child: Icon(
                              Icons.chat,
                              color:
                                  item.callStatus.trim().toLowerCase() == 'done'
                                  ? const Color.fromARGB(255, 207, 85, 85)
                                  : Colors.white30,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Tooltip(
                            message:
                                'Admission status: ${item.admissionStatus}',
                            child: Icon(
                              Icons.check_circle,
                              color:
                                  item.admissionStatus.trim().toLowerCase() ==
                                      'completed'
                                  ? const Color(0xFF19D18A)
                                  : Colors.white30,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: isCompact ? 14 : 16,
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

  /// The "Home" tab (gradient background, app bar, create-enquiry section and
  /// the enquiries list).
  Widget _buildHomeTab(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 380;
    final heroImageSize = (screenSize.width * 0.26)
        .clamp(72.0, 100.0)
        .toDouble();
    final sectionSpacing = (screenSize.height * 0.018)
        .clamp(8.0, 16.0)
        .toDouble();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1A55), Color(0xFF1B1340), Color(0xFF070A1B)],
          stops: [0.0, 0.3, 0.6],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // No back arrow on the dashboard (it is a root screen)
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Image.asset(
                "assets/images/sales_admin/core2web.png",
                width: isCompact ? 32 : 36.68,
                height: isCompact ? 26 : 30,
                fit: BoxFit.cover,
              ),
              Image.asset(
                "assets/images/sales_admin/c2wtext.png",
                width: isCompact ? 82 : 100,
                height: isCompact ? 50 : 60,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined, size: 32),
              color: Colors.white,
            ),
            // Tapping the avatar opens the profile screen
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: ClipOval(
                child: Image.asset(
                  "assets/images/sales_admin/profile.png",
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshEnquiries(context),
          color: const Color.fromRGBO(110, 75, 239, 1),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/sales_admin/notes.png",
                        width: heroImageSize,
                        height: heroImageSize,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create New Enquiry",
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Add student information to begin the course\nenquiry process.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.figtree(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(110, 75, 239, 1),
                              Color.fromRGBO(253, 85, 42, 1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CreateEquiry(),
                              ),
                            );
                            // Refresh the list when coming back
                            if (context.mounted) {
                              context.read<DashBoardBloc>().add(
                                const FetchEnquiriesEvent(),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            "Add Student Details",
                            style: GoogleFonts.figtree(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      const Divider(
                        color: Color.fromRGBO(255, 255, 255, 0.06),
                        thickness: 1,
                        height: 1,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 10 : 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(height: sectionSpacing),
                      BlocBuilder<DashBoardBloc, DashBoardState>(
                        builder: (context, state) {
                          final count = state is DashBoardLoaded
                              ? state.enquiries.length
                              : null;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _isTeamLeadMentorOrInstructor
                                        ? 'My Enquiries'
                                        : 'New Enquiry',
                                    style: GoogleFonts.figtree(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (count != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                          110,
                                          75,
                                          239,
                                          0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                            110,
                                            75,
                                            239,
                                            0.8,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        "$count",
                                        style: GoogleFonts.figtree(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  // "See all" is hidden for instructor_ / mentor_ / teamlead_
                                  if (_canOpenEnquiryOverview) ...[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Enquiry(),
                                          ),
                                        );
                                      },
                                      child:
                                          (AuthRepository.authEmail?.contains(
                                                    "salesadmin_",
                                                  ) ==
                                                  true ||
                                              AuthRepository.authEmail
                                                      ?.contains(
                                                        "superadmin_",
                                                      ) ==
                                                  true)
                                          ? Row(
                                              children: [
                                                Text(
                                                  "See all",
                                                  style: GoogleFonts.figtree(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.chevron_right,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildEnquiriesList(context, state),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHomeTab(context),
      _isExpenseManagerRole ? ExpenseManager() : IndividualExpenses(),
    ];
    if (_canViewUsers) {
      pages.add(const UsersScreen());
    }

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.contact_support_outlined),
        label: 'Enquiry',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.currency_rupee),
        label: 'Expense',
      ),
    ];
    if (_canViewUsers) {
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          label: 'Users',
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _isSalesAdmin
          ? null
          : CommonBottomNavigationBar(
              currentIndex: currentIndex,
              items: navItems,
              onTap: (index) {
                if (index < pages.length) {
                  if (index != currentIndex) {
                    context.read<ExpenseFilterBloc>().add(
                      ResetExpenseFilters(),
                    );
                  }
                  setState(() {
                    currentIndex = index;
                  });
                }
              },
            ),
    );
  }
}
