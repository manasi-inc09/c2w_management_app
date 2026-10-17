import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/core/commom_bottom_navigationbar.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/manage_categories.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/memberslist.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/transaction_details.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/view_all_expenses.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/wallet_screen.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/floating_button.dart';
import 'package:flutter/material.dart';

class ExpenseManager extends StatefulWidget {
  const ExpenseManager({super.key});

  @override
  State<ExpenseManager> createState() => _ExpenseManagerState();
}

class _ExpenseManagerState extends State<ExpenseManager> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['This Week', 'This Month', 'This Year'];
  List<Map<dynamic, dynamic>> expenseList = [
    {
      "name": "sumit",
      "Rupee": "180₹",
      "expense": "Stationary",
      "Date": "14 DEC",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F1424);
    const cardColor = Color(0xFF1E2638);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Colors.white),
        title: Text(
          "Expense Manager",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(31, 34, 49, 1),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>WalletScreen()));
            },
            child: Icon(Icons.account_balance_wallet, color: Colors.amber)),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(31, 34, 49, 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 50,
                        width: 360,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(53, 56, 69, 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _selectedFilterIndex = _filters.indexOf(
                                  "This Week",
                                );
                                setState(() {});
                              },

                              child: Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: (_selectedFilterIndex == 0)
                                      ? Colors.blue
                                      : Color.fromRGBO(53, 56, 69, 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "This Week",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight(600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectedFilterIndex = _filters.indexOf(
                                  "This Month",
                                );
                                setState(() {});
                              },
                              child: Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: (_selectedFilterIndex == 1)
                                      ? Colors.blue
                                      : Color.fromRGBO(53, 56, 69, 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "This Month",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight(600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectedFilterIndex = _filters.indexOf(
                                  "This Year",
                                );
                                setState(() {});
                              },
                              child: Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: (_selectedFilterIndex == 2)
                                      ? Colors.blue
                                      : Color.fromRGBO(53, 56, 69, 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "This Year",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight(600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Paid Amount',
                            value: '2000',
                            icon: Icons.trending_up,
                            iconColor: const Color(0xFF00D09C),
                            iconBgColor: const Color(0xFF0D3838),
                            cardBg: cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              
                            },
                            child: _buildMetricCard(
                              title: 'Unpaid Amount',
                              value: '5000',
                              icon: Icons.trending_down,
                              iconColor: const Color(0xFFFF5271),
                              iconBgColor: const Color(0xFF3E1D2D),
                              cardBg: cardColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Positioned(
                    top: 200,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>ManageCategories()));
                            },
                            child: _buildMetricCard(
                              title: 'Categories',
                              value: '12',
                              icon: Icons.check_circle_outline,
                              iconColor: Color.fromRGBO(252, 174, 16, 1),
                            
                              iconBgColor: Color.fromRGBO(252, 174, 16, 0.2),
                              cardBg: cardColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>MembersList()));
                            },
                            child: _buildMetricCard(
                              title: 'Members',
                              value: '18',
                              icon: Icons.person_outline,
                              iconColor: Color.fromRGBO(5, 165, 255, 1),
                              iconBgColor: const Color(0xFF143048),
                              cardBg: cardColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight(500),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewAllExpenses()));
                    },
                    child: Text(
                      "See all >",
                      style: TextStyle(
                        color: Color.fromRGBO(5, 165, 255, 1),
                        fontSize: 14,
                        fontWeight: FontWeight(500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: expenseList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>TransactionDetails()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: const Color.fromRGBO(15, 20, 36, 1),
                      child: Row(
                        children: [
                          // avatar circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255, 179, 167, 1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'A',
                              style: TextStyle(
                                color: Color.fromRGBO(158, 54, 42, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                    
                         
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expenseList[index]['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  expenseList[index]['expense'],
                                  style: TextStyle(
                                    color: Color.fromRGBO(126, 139, 155, 1),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    
                         
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                expenseList[index]['Rupee'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                expenseList[index]['Date'],
                                style: TextStyle(
                                  color: Color.fromRGBO(126, 139, 155, 1),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          //   Positioned(
          //           right: 20,
          //           bottom: 34,
          //           child: GestureDetector(
          //             onTap: () {},
          //             child: Container(
          //               width: 56,
          //               height: 56,
          //               decoration: const BoxDecoration(
          //                 color: Color(0xFF0091FF),
          //                 shape: BoxShape.circle,
          //               ),
          //               child: const Icon(Icons.add, color: Colors.white, size: 28),
          //             ),
          //           ),
          //         ),
        ],
      ),
      floatingActionButton: FloatingButton.getFloatingButton()
//bottomNavigationBar: CommonBottomNavigationBar(currentIndex: , onTap: onTap),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}
