import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/create_transaction_page.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/floating_button.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/monthwise_expense_listview.dart';
import 'package:flutter/material.dart';

class ViewAllExpenses extends StatefulWidget {
  const ViewAllExpenses({super.key});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {

List<String> filterList=["Categories","Members","dd-mm-yyyy"];
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
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
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
          child: const Icon(
            Icons.search_outlined,
            color: Colors.white,
          ),
        ),
      ],

      bottom: CommonFilters().getCommonFilter(context, appliedFilters,filterList),
    ),

    body: MonthwiseExpenseListview()
        .getMonthwiseExpenseListview(MonthwiseExpenseListview().transactionData),
   floatingActionButton:FloatingButton.getFloatingButton()
  );
}
}
