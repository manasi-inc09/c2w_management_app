import 'package:c2w_management_app/features/expense/presentation/screens/transaction_details.dart';
import 'package:flutter/material.dart';

class MonthwiseExpenseListview {
  final List<Map<String, dynamic>> transactionData = [
  {
    'year': '2025',
    'month': 'December',
    'totalAmount': '₹8,590',
    'transactions': [
      {
        'initial': 'A',
        'avatarBg': const Color.fromRGBO(255, 179, 167, 1),
        'avatarTextColor': const Color.fromRGBO(158, 54, 42, 1),
        'name': 'Anuja Shinde',
        'subtitle': 'Stationery, Notebook, Pen',
        'amount': '₹86',
        'date': '14 Dec',
      },
      {
        'initial': 'S',
        'avatarBg': const Color.fromRGBO(187, 198, 255, 1),
        'avatarTextColor': const Color.fromRGBO(50, 63, 148, 1),
        'name': 'Saaquib Mohammad',
        'subtitle': 'Breakfast',
        'amount': '₹350',
        'date': '14 Dec',
      },
      {
        'initial': 'K',
        'avatarBg': const Color.fromRGBO(185, 246, 202, 1),
        'avatarTextColor': const Color.fromRGBO(27, 94, 32, 1),
        'name': 'Kapil Ojha',
        'subtitle': 'New Mobile Sim',
        'amount': '₹899',
        'date': '14 Dec',
      },
      {
        'initial': 'A',
        'avatarBg': const Color.fromRGBO(225, 190, 231, 1),
        'avatarTextColor': const Color.fromRGBO(106, 27, 154, 1),
        'name': 'Arya Sharma',
        'subtitle': 'Hard Drive 1TB',
        'amount': '₹4,500',
        'date': '14 Dec',
      },
      {
        'initial': 'V',
        'avatarBg': const Color.fromRGBO(255, 236, 179, 1),
        'avatarTextColor': const Color.fromRGBO(191, 54, 12, 1),
        'name': 'Varnika Aditi Singh',
        'subtitle': 'Certificates Printing',
        'amount': '₹2,300',
        'date': '14 Dec',
      },
      {
        'initial': 'S',
        'avatarBg': const Color.fromRGBO(248, 187, 208, 1),
        'avatarTextColor': const Color.fromRGBO(173, 20, 87, 1),
        'name': 'Sibani Mohapatra',
        'subtitle': 'Cake for birthday',
        'amount': '₹455',
        'date': '14 Dec',
      },
    ],
  },
  {
    'year': '2025',
    'month': 'November',
    'totalAmount': '₹6,420',
    'transactions': [
      {
        'initial': 'R',
        'avatarBg': const Color.fromRGBO(178, 235, 242, 1),
        'avatarTextColor': const Color.fromRGBO(0, 96, 100, 1),
        'name': 'Rohan Kulkarni',
        'subtitle': 'Team Dinner, Drinks',
        'amount': '₹3,200',
        'date': '28 Nov',
      },
      {
        'initial': 'P',
        'avatarBg': const Color.fromRGBO(255, 204, 188, 1),
        'avatarTextColor': const Color.fromRGBO(191, 54, 12, 1),
        'name': 'Pooja Deshmukh',
        'subtitle': 'Groceries, Dairy',
        'amount': '₹1,450',
        'date': '22 Nov',
      },
      {
        'initial': 'M',
        'avatarBg': const Color.fromRGBO(209, 196, 233, 1),
        'avatarTextColor': const Color.fromRGBO(69, 39, 160, 1),
        'name': 'Manish Patil',
        'subtitle': 'Fuel & Toll',
        'amount': '₹1,100',
        'date': '15 Nov',
      },
      {
        'initial': 'N',
        'avatarBg': const Color.fromRGBO(255, 245, 157, 1),
        'avatarTextColor': const Color.fromRGBO(130, 119, 23, 1),
        'name': 'Neha Joshi',
        'subtitle': 'Office Supplies',
        'amount': '₹670',
        'date': '04 Nov',
      },
    ],
  },
  {
    'year': '2025',
    'month': 'October',
    'totalAmount': '₹11,250',
    'transactions': [
      {
        'initial': 'A',
        'avatarBg': const Color.fromRGBO(200, 230, 201, 1),
        'avatarTextColor': const Color.fromRGBO(27, 94, 32, 1),
        'name': 'Aditya Verma',
        'subtitle': 'Diwali Lights, Decor',
        'amount': '₹4,800',
        'date': '29 Oct',
      },
      {
        'initial': 'T',
        'avatarBg': const Color.fromRGBO(255, 205, 210, 1),
        'avatarTextColor': const Color.fromRGBO(183, 28, 28, 1),
        'name': 'Tanmay Roy',
        'subtitle': 'Sweets & Gift Boxes',
        'amount': '₹3,650',
        'date': '25 Oct',
      },
      {
        'initial': 'K',
        'avatarBg': const Color.fromRGBO(187, 222, 251, 1),
        'avatarTextColor': const Color.fromRGBO(13, 71, 161, 1),
        'name': 'Kritika Sen',
        'subtitle': 'Cab Booking',
        'amount': '₹720',
        'date': '18 Oct',
      },
      {
        'initial': 'G',
        'avatarBg': const Color.fromRGBO(220, 237, 200, 1),
        'avatarTextColor': const Color.fromRGBO(51, 105, 30, 1),
        'name': 'Gaurav Mehta',
        'subtitle': 'Broadband Bill',
        'amount': '₹2,080',
        'date': '05 Oct',
      },
    ],
  },
];
  Widget getMonthwiseExpenseListview(List<Map<String, dynamic>> transactionData){
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: transactionData.length,
      itemBuilder: (context, groupIndex) {
        final group = transactionData[groupIndex];
        final List items = group['transactions'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // month header
            Padding(
              
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group['year'],
                        style: const TextStyle(
                          color: Color.fromRGBO(126, 139, 155, 1),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group['month'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    group['totalAmount'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // items inside this month
            ...items.map((item) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetails(group)));
                },
                child: Container(
                  color: Color.fromRGBO(7, 10, 27, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item['avatarBg'],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['initial'],
                          style: TextStyle(
                            color: item['avatarTextColor'],
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
                              item['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'],
                              style: const TextStyle(
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
                            item['amount'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['date'],
                            style: const TextStyle(
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
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}