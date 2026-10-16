import 'package:c2w_management_app/core/app_theme.dart';
import 'package:flutter/material.dart';

class MonthwiseIndividualListview {
  Widget getMonthwiseExpenseListview(List<Map<String,dynamic>> transactionData){
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
        Container(
          decoration: BoxDecoration(
            color: AppTheme().appBarBackgroundColor
          ),
          child: Padding(
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
        ),

        // items inside this month
        ...items.map((item) {
          return Container(
            color: const Color.fromRGBO(7, 10, 27, 1),
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
                        item['title'], // Updated key from 'name' to 'title'
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['category'], // Updated key from 'subtitle' to 'category'
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
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  },
);
  }
}