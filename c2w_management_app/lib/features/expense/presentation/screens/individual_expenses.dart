import 'dart:developer';

import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/enquiry/presentation/widgets/filters.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/expense_manager.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/monthwise_expense_listview.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

  final List<Map<String, dynamic>> transactionData = [
    {
      'year': '2025',
      'month': 'December',
      'totalAmount': '₹5835',
      'transactions': [
        {
          'initial': 'S',
          'avatarBg': const Color.fromRGBO(255, 179, 167, 1),
          'avatarTextColor': const Color.fromRGBO(158, 54, 42, 1),
          'title': 'Stationery, Notebook, Pen',
          'category': 'Event • SuperX Flutter',
          'amount': '₹86',
          'date': '14 Dec',
        },
        {
          'initial': 'S',
          'avatarBg': const Color.fromRGBO(187, 198, 255, 1),
          'avatarTextColor': const Color.fromRGBO(50, 63, 148, 1),
          'title': 'Breakfast',
          'category': 'Event • SuperX Flutter',
          'amount': '₹350',
          'date': '14 Dec',
        },
        {
          'initial': 'K',
          'avatarBg': const Color.fromRGBO(185, 246, 202, 1),
          'avatarTextColor': const Color.fromRGBO(27, 94, 32, 1),
          'title': 'New Mobile Sim',
          'category': 'Electronic Gadgets',
          'amount': '₹899',
          'date': '14 Dec',
        },
        {
          'initial': 'A',
          'avatarBg': const Color.fromRGBO(225, 190, 231, 1),
          'avatarTextColor': const Color.fromRGBO(106, 27, 154, 1),
          'title': 'Hard Drive 1TB',
          'category': 'Electronic Gadgets',
          'amount': '₹4500',
          'date': '14 Dec',
        },
      ],
    },
    {
      'year': '2025',
      'month': 'November',
      'totalAmount': '₹2755',
      'transactions': [
        {
          'initial': 'N',
          'avatarBg': const Color.fromRGBO(255, 236, 179, 1),
          'avatarTextColor': const Color.fromRGBO(191, 54, 12, 1),
          'title': 'November Expense',
          'category': 'Event • SuperX Flutter',
          'amount': '₹2755',
          'date': '28 Nov',
        },
        {
          'initial': 'S',
          'avatarBg': const Color.fromRGBO(187, 198, 255, 1),
          'avatarTextColor': const Color.fromRGBO(50, 63, 148, 1),
          'title': 'Breakfast',
          'category': 'Event • SuperX Flutter',
          'amount': '₹350',
          'date': '14 Dec',
        },
        {
          'initial': 'K',
          'avatarBg': const Color.fromRGBO(185, 246, 202, 1),
          'avatarTextColor': const Color.fromRGBO(27, 94, 32, 1),
          'title': 'New Mobile Sim',
          'category': 'Electronic Gadgets',
          'amount': '₹899',
          'date': '14 Dec',
        },
        {
          'initial': 'A',
          'avatarBg': const Color.fromRGBO(225, 190, 231, 1),
          'avatarTextColor': const Color.fromRGBO(106, 27, 154, 1),
          'title': 'Hard Drive 1TB',
          'category': 'Electronic Gadgets',
          'amount': '₹4500',
          'date': '14 Dec',
        },
      ],
    },
  ];

class IndividualExpenses extends StatefulWidget {
  const IndividualExpenses({super.key});

  @override
  State<IndividualExpenses> createState() => _IndividualExpensesState();
}

class _IndividualExpensesState extends State<IndividualExpenses> {
  String selectedOption = "Option 1";
  List<String> individual_FilterList = ["Event |  dsdsCPL event", "Subodh"];
  //List<String> filterList=["Categories","Members","dd-mm-yyyy"];
Map<String,String> appliedFilters={};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().appBarBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),

        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(255, 255, 255, 0.1),
              ),
              color: Color.fromRGBO(255, 255, 255, 0.06),
            ),
            child: const Icon(Icons.search_outlined, color: Colors.white),
          ),
        ],
          bottom: CommonFilters().getCommonFilter(context, appliedFilters,individual_FilterList),
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(60),

        //   child: Padding(
        //     padding: const EdgeInsets.only(bottom: 10),

        //     child: Row(
        //       children: [
        //         const SizedBox(width: 20),

        //         Stack(
        //           children: [
        //             GestureDetector(
        //               onTap: () async {
        //                 final result = await showFilterSheet(
        //                   context,
        //                   initialFilters: appliedFilters,
        //                 );

        //                 if (result != null) {
        //                   setState(() {
        //                     appliedFilters = result; // page rebuilds after this
        //                   });
        //                 }
        //               },
        //               child: const Icon(
        //                 Icons.filter_alt_outlined,
        //                 color: Colors.white,
        //                 size: 35,
        //               ),
        //             ),
        //             Positioned(
        //               right: 0,

        //               child: Container(
        //                 height: 18,
        //                 width: 18,

        //                 decoration: BoxDecoration(
        //                   shape: BoxShape.circle,
        //                   color: Colors.blue,
        //                 ),
        //                 child: Center(
        //                   child: Text(
        //                     "2",
        //                     style: TextStyle(
        //                       color: Colors.white,
        //                       fontSize: 12,
        //                       fontWeight: FontWeight(600),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),

        //         const SizedBox(width: 10),

        //         // Important correction
        //         Expanded(
        //           child: SizedBox(
        //             height: 40,

        //             child: ListView.builder(
        //               scrollDirection: Axis.horizontal,

        //               itemCount: individual_FilterList.length,

        //               itemBuilder: (context, index) {
        //                 return Container(
        //                   height: 40,
        //                   padding: const EdgeInsets.symmetric(
        //                     horizontal: 18,
        //                     vertical: 8,
        //                   ),

        //                   margin: const EdgeInsets.only(right: 10),

        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(30),
        //                     border: Border.all(
        //                       width: 1,
        //                       color: Color.fromRGBO(255, 255, 255, 0.1),
        //                     ),
        //                     color: const Color.fromRGBO(255, 255, 255, 0.06),
        //                   ),

        //                   child: Center(
        //                     child: Text(
        //                       individual_FilterList[index],
        //                       style: TextStyle(
        //                         fontSize: 14,
        //                         fontWeight: FontWeight.w400,
        //                         color: Colors.white,
        //                       ),
        //                     ),
        //                   ),
        //                 );
        //               },
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  //width: screenWidth*0.5,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(7, 10, 27, 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹8590",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight(500),
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Total",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(height: 65, width: 1, color: Colors.white24),

              Expanded(
                child: Container(
                  height: 100,
                  //width: screenWidth*0.5,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(7, 10, 27, 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹0",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight(500),
                          color: Color.fromRGBO(28, 205, 128, 1),
                        ),
                      ),
                      Text(
                        "Settled",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight(400),
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: MonthwiseIndividualListview().getMonthwiseExpenseListview(
              transactionData,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SettleButton().getSettleButton(
        context,(loginAs=="INSTRUCTOR"||loginAs=="SUPERADMIN")?"Settle":"Add Transaction",
        container: (loginAs=="Instructor")?getBottomSheetOpen():null,onTap: () {
          if((loginAs=="INSTRUCTOR")){

          }else{
            print("Inside else");
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateNewTransaction()));
          }
        },
      ),
    );
  }

  
Widget getExpensePage() {
  return const ExpenseManager();
}


  void handleRadioChange(String? value) {
    if (value != null) {
      setState(() {
        selectedOption = value;
      });
    }
  }

  Widget getBottomSheetOpen() {
    String localSelectedOption = selectedOption;
    bool isChecked = false;

    return BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void handleCheckBox(bool? value) {
              if (value != null) {
                setState(() {
                  isChecked = value; // Update your state variable
                });
              }
            }

            // Helper widget to build each custom radio box
            Widget buildRadioBox({
              required String title,
              required String value,
            }) {
              bool isSelected = localSelectedOption == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      localSelectedOption = value;
                    });
                    this.setState(() {
                      selectedOption = value; // Update main page state
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                        7,
                        10,
                        27,
                        1,
                      ), // Dark container background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors
                                  .grey
                                  .shade800, // Blue border if selected, grey otherwise
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Custom Radio Circle Indicator
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppTheme()
                    .appBarBackgroundColor, // Sheet background color matching your theme
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag handle bar like in the image
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Row containing both option boxes side-by-side
                  Row(
                    children: [
                      buildRadioBox(title: "Total", value: "Option 1"),
                      const SizedBox(width: 12),
                      buildRadioBox(title: "Custom", value: "Option 2"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "8590",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  const SizedBox(height: 10),
                  Container(
                    height: 60,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(90, 36, 118, 1),
                          Color.fromRGBO(59, 46, 116, 1),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Settle from Wallet",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight(400),
                                  color: Colors.white,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "Available Balance: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "10,000",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight
                                            .w500, // Optional: slightly bolder for emphasis
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Checkbox(
                          value: isChecked,
                          onChanged: handleCheckBox,
                          activeColor: Colors.green,
                          side: BorderSide(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SettleButton().getSettleButton(context,(loginAs=="Instructor")?"Settle":"Add Transaction")
                ],
              ),
            );
          },
        );
      },
    );
  }
}
