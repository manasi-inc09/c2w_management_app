// import 'package:c2w_management_app/core/commom_bottom_navigationbar.dart';
// import 'package:c2w_management_app/features/Profile/presentation/screens/profile.dart';
// import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/screens/create_equiry.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
// import 'package:c2w_management_app/features/enquiry/enquiry_overview.dart';
// import 'package:c2w_management_app/features/enquiry/presentation/widgets/enquiry_list.dart';
// import 'package:c2w_management_app/features/expense/presentation/screens/expense_manager.dart';
// import 'package:c2w_management_app/features/expense/presentation/screens/individual_expenses.dart';
// import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
// import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DashboardView extends StatefulWidget {
//   String? isLogin;
//   DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   int currentIndex = 0;
//   String? authEmail;

//   @override
// void initState() {
//   super.initState();

//   context.read<DashBoardBloc>().add(
//     const FetchEnquiriesEvent(),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: currentIndex,
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF2A1A55),
//                   Color(0xFF1B1340),
//                   Color(0xFF070A1B),
//                 ],
//                 stops: [0.0, 0.3, 0.6],
//               ),
//             ),
//             child: Scaffold(
//               backgroundColor: Colors.transparent,
//               appBar: AppBar(
//                 automaticallyImplyLeading: false,
//                 backgroundColor: Colors.transparent,
//                 surfaceTintColor: Colors.transparent,
//                 iconTheme: const IconThemeData(color: Colors.white),
//                 title: Row(
//                   children: [
//                     Image.asset(
//                       "assets/images/sales_admin/core2web.png",
//                       width: 36.68,
//                       height: 30,
//                       fit: BoxFit.cover,
//                     ),
//                     Image.asset(
//                       "assets/images/sales_admin/c2wtext.png",
//                       width: 100,
//                       height: 60,
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.notifications_outlined, size: 32),
//                     color: Colors.white,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => ProfileScreen(),
//                         ),
//                       );
//                     },
//                     child: ClipOval(
//                       child: Image.asset(
//                         "assets/images/sales_admin/profile.png",
//                         width: 38,
//                         height: 38,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                 ],
//               ),

//               body: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Center(
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             "assets/images/sales_admin/notes.png",
//                             width: 96.92,
//                             height: 94.94,
//                             fit: BoxFit.cover,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Create New Enquiry",
//                             style: GoogleFonts.figtree(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "Add student information to begin the course\nenquiry process.",
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.figtree(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   Color.fromRGBO(110, 75, 239, 1),
//                                   Color.fromRGBO(253, 85, 42, 1),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) => CreateEquiry(),
//                                   ),
//                                 );
//                               },
//                               icon: const Icon(
//                                 Icons.add,
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                               label: Text(
//                                 "Add Student Details",
//                                 style: GoogleFonts.figtree(
//                                   color: Colors.white,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 shadowColor: Colors.transparent,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 14,
//                                   vertical: 10,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           const Divider(
//                             color: Color.fromRGBO(255, 255, 255, 0.06),
//                             thickness: 1,
//                             height: 1,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Text(
//                                 "New Enquiry",
//                                 style: GoogleFonts.figtree(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               const Spacer(),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => Enquiry(),
//                                     ),
//                                   );
//                                 },
//                                 child: Visibility(
//                                   visible:
//                                       !(AuthRepository.authEmail!.contains(
//                                             "instructor_",
//                                           ) ||
//                                           AuthRepository.authEmail!.contains(
//                                             "mentor_",
//                                           ) ||
//                                           AuthRepository.authEmail!.contains(
//                                             "teamlead_",
//                                           )),
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         "See all",
//                                         style: GoogleFonts.figtree(
//                                           fontSize: 16,
//                                           color: Colors.blue,
//                                         ),
//                                       ),
//                                       const Icon(
//                                         Icons.chevron_right,
//                                         color: Colors.blue,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           EnquiryList(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           (AuthRepository.authEmail!.contains("_instructor")|| AuthRepository.authEmail!.contains("_superadmin")) ? ExpenseManager() : IndividualExpenses(),
//         ],
//       ),

//       bottomNavigationBar: AuthRepository.authEmail!.contains("salesadmin_")
//           ? null
//           : CommonBottomNavigationBar(
//               currentIndex: currentIndex,
//               onTap: (index) {
//                 setState(() {
//                   currentIndex = index;
//                 });
//               },
//             ),
//     );
//   }
// }

// import 'dart:developer';

// import 'package:c2w_management_app/features/Profile/presentation/screens/profile.dart';
// import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/screens/create_equiry.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardEvent.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_overview.dart';
// import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/enquiry_person_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   @override
//   Widget build(BuildContext context) {
//     // If DashBoardBloc is already provided by an ancestor (e.g., in main.dart), reuse it;
//     // otherwise, provide it locally so the Dashboard works out-of-the-box.
//     try {
//       context.read<DashBoardBloc>();
//       return const _DashboardViewContent();
//     } catch (_) {
//       return BlocProvider<DashBoardBloc>(
//         create: (context) => DashBoardBloc()..add(const FetchEnquiriesEvent()),
//         child: const _DashboardViewContent(),
//       );
//     }
//   }
// }

// class _DashboardViewContent extends StatefulWidget {
//   const _DashboardViewContent();

//   @override
//   State<_DashboardViewContent> createState() => _DashboardViewContentState();
// }

// class _DashboardViewContentState extends State<_DashboardViewContent> {
//   @override
//   void initState() {
//     super.initState();
//     // Dispatch fetch event only if state is initial to prevent repeated fetches on rebuilds
//     final bloc = context.read<DashBoardBloc>();
//     if (bloc.state is DashBoardInitial) {
//       bloc.add(const FetchEnquiriesEvent());
//     }
//   }

//   Color _modeColor(String mode) {
//     switch (mode.toLowerCase()) {
//       case 'online':
//         return Colors.green;
//       case 'offline':
//         return const Color.fromRGBO(5, 164, 255, 1);
//       case 'recorded':
//         return Colors.orange;
//       default:
//         return const Color.fromRGBO(5, 164, 255, 1);
//     }
//   }

//   Widget _buildEnquiriesList(BuildContext context, DashBoardState state) {
//     if (state is DashBoardLoading || state is DashBoardInitial) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 36),
//         child: Center(
//           child: CircularProgressIndicator(
//             color: Color.fromRGBO(110, 75, 239, 1),
//           ),
//         ),
//       );
//     }

//     if (state is DashBoardError) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//         child: Center(
//           child: Column(
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.redAccent,
//                 size: 40,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 state.message,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.figtree(
//                   color: Colors.white70,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   context.read<DashBoardBloc>().add(
//                         const FetchEnquiriesEvent(),
//                       );
//                 },
//                 icon: const Icon(
//                   Icons.refresh,
//                   size: 16,
//                   color: Colors.white,
//                 ),
//                 label: Text(
//                   'Retry',
//                   style: GoogleFonts.figtree(
//                     color: Colors.white,
//                     fontSize: 13,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF161B2E),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (state is DashBoardEmpty ||
//         (state is DashBoardLoaded && state.enquiries.isEmpty)) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
//         child: Center(
//           child: Column(
//             children: [
//               const Icon(
//                 Icons.inbox_outlined,
//                 color: Colors.white38,
//                 size: 44,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'No enquiries found',
//                 style: GoogleFonts.figtree(
//                   color: Colors.white54,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (state is DashBoardLoaded) {
//       return ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         itemCount: state.enquiries.length,
//         itemBuilder: (context, index) {
//           final item = state.enquiries[index];
//           return _buildEnquiryCard(context, item);
//         },
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   Widget _buildEnquiryCard(BuildContext context, EnquiryModel item) {
//     final modeColor = _modeColor(item.mode);
//     final displayName = item.studentName.isNotEmpty
//         ? item.studentName.toUpperCase()
//         : 'UNNAMED STUDENT';

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Material(
//         color: const Color(0xFF161B2E),
//         borderRadius: BorderRadius.circular(10),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => EnquiryPersonProfile(enquiry: item),
//               ),
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Container(width: 3, height: 50, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             item.formattedDate,
//                             style: GoogleFonts.figtree(
//                               color: Colors.white54,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             width: 1,
//                             height: 12,
//                             color: Colors.white24,
//                           ),
//                           const SizedBox(width: 8),
//                           if (item.studentFeedback.isNotEmpty)
//                             const Icon(
//                               Icons.chat_bubble,
//                               color: Colors.redAccent,
//                               size: 14,
//                             ),
//                           if (item.mode.isNotEmpty) ...[
//                             const SizedBox(width: 6),
//                             const Icon(
//                               Icons.check_circle,
//                               color: Colors.green,
//                               size: 16,
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         displayName,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.figtree(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         item.interestedBatchDisplay,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.figtree(
//                           color: Colors.white54,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     if (item.mode.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: modeColor.withValues(alpha: 0.15),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           '• ${item.mode}',
//                           style: GoogleFonts.figtree(
//                             color: modeColor,
//                             fontSize: 11,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 10),
//                     Text(
//                       item.mobileNo.isNotEmpty ? item.mobileNo : 'N/A',
//                       style: GoogleFonts.figtree(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF2A1A55), Color(0xFF1B1340), Color(0xFF070A1B)],
//           stops: [0.0, 0.3, 0.6],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           surfaceTintColor: Colors.transparent,
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: Row(
//             children: [
//               Image.asset(
//                 "assets/images/sales_admin/core2web.png",
//                 width: 36.68,
//                 height: 30,
//                 fit: BoxFit.cover,
//               ),
//               Image.asset(
//                 "assets/images/sales_admin/c2wtext.png",
//                 width: 100,
//                 height: 60,
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {},
//               icon: const Icon(Icons.notifications_outlined, size: 32),
//               color: Colors.white,
//             ),
//             GestureDetector(
//               onTap: (){
//                 log("entering into profile...");
//                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileScreen(),));
//               },
//               child: ClipOval(
//                 child: Image.asset(
//                   "assets/images/sales_admin/profile.png",
//                   width: 38,
//                   height: 38,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       "assets/images/sales_admin/notes.png",
//                       width: 96.92,
//                       height: 94.94,
//                       fit: BoxFit.cover,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Create New Enquiry",
//                       style: GoogleFonts.figtree(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       "Add student information to begin the course\nenquiry process.",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.figtree(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             Color.fromRGBO(110, 75, 239, 1),
//                             Color.fromRGBO(253, 85, 42, 1),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: ElevatedButton.icon(
//                         onPressed: () async {
//                           await Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => const CreateEquiry(),
//                             ),
//                           );
//                           if (context.mounted) {
//                             context
//                                 .read<DashBoardBloc>()
//                                 .add(const FetchEnquiriesEvent());
//                           }
//                         },
//                         icon: const Icon(
//                           Icons.add,
//                           color: Colors.white,
//                           size: 18,
//                         ),
//                         label: Text(
//                           "Add Student Details",
//                           style: GoogleFonts.figtree(
//                             color: Colors.white,
//                             fontSize: 13,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 10,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Divider(
//                       color: Color.fromRGBO(255, 255, 255, 0.06),
//                       thickness: 1,
//                       height: 1,
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     const SizedBox(height: 20),
//                     BlocBuilder<DashBoardBloc, DashBoardState>(
//                       builder: (context, state) {
//                         final count = state is DashBoardLoaded
//                             ? state.enquiries.length
//                             : null;

//                         return Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "New Enquiry",
//                                   style: GoogleFonts.figtree(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 if (count != null) ...[
//                                   const SizedBox(width: 8),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 2,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: const Color.fromRGBO(
//                                         110,
//                                         75,
//                                         239,
//                                         0.25,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                       border: Border.all(
//                                         color: const Color.fromRGBO(
//                                           110,
//                                           75,
//                                           239,
//                                           0.8,
//                                         ),
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       "$count",
//                                       style: GoogleFonts.figtree(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                                 const Spacer(),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).push(
//                                       MaterialPageRoute(
//                                         builder: (context) => Enquiry(),
//                                       ),
//                                     );
//                                   },
//                                   child: Text(
//                                     "See all",
//                                     style: GoogleFonts.figtree(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                                 const Icon(
//                                   Icons.chevron_right,
//                                   color: Colors.grey,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             _buildEnquiriesList(context, state),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
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
    // If DashBoardBloc is already provided by an ancestor (e.g., in main.dart), reuse it;
    // otherwise, provide it locally so the Dashboard works out-of-the-box.
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
    // Refresh on each dashboard entry so results use the current account's access.
    final bloc = context.read<DashBoardBloc>();
    bloc.add(const FetchEnquiriesEvent());
  }

  // ---------------------------------------------------------------------------
  // Role helpers (based on the logged-in user's email)
  // ---------------------------------------------------------------------------

  /// Null-safe access to the logged in email (avoids `authEmail!` crashes).
  String get _email => AuthRepository.authEmail ?? '';

  /// Sales admin has no bottom navigation bar.
  bool get _isSalesAdmin => _email.contains("salesadmin_");

  /// Instructor / mentor / team lead cannot see the "See all" button.
  bool get _canSeeAllEnquiries =>
      !(_email.contains("instructor_") ||
          _email.contains("mentor_") ||
          _email.contains("teamlead_"));

  /// Instructor / super admin get the ExpenseManager, everyone else gets
  /// their own IndividualExpenses screen.
  bool get _isExpenseManagerRole =>
      _email.contains("instructor") || _email.contains("superadmin");

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

    if (state is DashBoardEmpty ||
        (state is DashBoardLoaded && state.enquiries.isEmpty)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                color: Colors.white38,
                size: 44,
              ),
              const SizedBox(height: 10),
              Text(
                'No enquiries found',
                style: GoogleFonts.figtree(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
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
            if(AuthRepository.authEmail!.contains("salesadmin_") || AuthRepository.authEmail!.contains("superadmin_") ){
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

  /// The "Home" tab (gradient background, app bar, create-enquiry section and
  /// the enquiries list).
  Widget _buildHomeTab(BuildContext context) {
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
                width: 36.68,
                height: 30,
                fit: BoxFit.cover,
              ),
              Image.asset(
                "assets/images/sales_admin/c2wtext.png",
                width: 100,
                height: 60,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/sales_admin/notes.png",
                      width: 96.92,
                      height: 94.94,
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
                            context
                                .read<DashBoardBloc>()
                                .add(const FetchEnquiriesEvent());
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
                    const SizedBox(height: 20),
                    const Divider(
                      color: Color.fromRGBO(255, 255, 255, 0.06),
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const SizedBox(height: 20),
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
                                  "New Enquiry",
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
                                if (_canSeeAllEnquiries) ...[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => Enquiry(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "See all",
                                      style: GoogleFonts.figtree(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tab 0: Home (enquiries) | Tab 1: Expenses (role based)
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildHomeTab(context),
          _isExpenseManagerRole ? ExpenseManager() : IndividualExpenses(),
        ],
      ),
      // Sales admin does not get a bottom navigation bar
      bottomNavigationBar: _isSalesAdmin
          ? null
          : CommonBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
    );
  }
}
