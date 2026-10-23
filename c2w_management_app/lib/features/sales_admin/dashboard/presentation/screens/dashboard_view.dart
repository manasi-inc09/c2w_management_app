import 'package:c2w_management_app/core/commom_bottom_navigationbar.dart';
import 'package:c2w_management_app/features/Profile/presentation/screens/profile.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/screens/create_equiry.dart';
import 'package:c2w_management_app/features/enquiry/enquiry_overview.dart';
import 'package:c2w_management_app/features/enquiry/presentation/widgets/enquiry_list.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/expense_manager.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends StatefulWidget {
  String? isLogin;
  DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int currentIndex = 0;
  String? authEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A1A55),
                  Color(0xFF1B1340),
                  Color(0xFF070A1B),
                ],
                stops: [0.0, 0.3, 0.6],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
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
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
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
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CreateEquiry(),
                                  ),
                                );
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
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Enquiry(),
                                    ),
                                  );
                                },
                                child: Visibility(
                                  visible:
                                      !(AuthRepository.authEmail!.contains(
                                            "instructor_",
                                          ) ||
                                          AuthRepository.authEmail!.contains(
                                            "mentor_",
                                          ) ||
                                          AuthRepository.authEmail!.contains(
                                            "teamlead_",
                                          )),
                                  child: Row(
                                    children: [
                                      Text(
                                        "See all",
                                        style: GoogleFonts.figtree(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          EnquiryList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          (AuthRepository.authEmail!.contains("superadmin_") ||
                  AuthRepository.authEmail!.contains("instructor_") ||
                  AuthRepository.authEmail!.contains("salesadmin_"))
              ? ExpenseManager()
              : IndividualExpenses(),
        ],
      ),

      bottomNavigationBar: AuthRepository.authEmail!.contains("salesadmin_")
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
