import 'package:c2w_management_app/core/app_theme.dart';
//import 'package:c2w_management_app/features/super_admin/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/monthwise_expense_listview.dart';
//import 'package:c2w_management_app/features/super_admin/presentation/widgets/monthwise_individual_listview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF080B1B),

  appBar: PreferredSize(
    
    preferredSize: const Size.fromHeight(220),

    child: AppBar(
      
      automaticallyImplyLeading: false,
      toolbarHeight: 220,
      titleSpacing: 0,
      backgroundColor: Color.fromRGBO(32, 34, 58, 1),
      elevation: 0,

      title: Container(
        height: 220,
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:Alignment.bottomCenter,
            colors: [
            Color.fromRGBO(32, 34, 58, 1),Color.fromRGBO(32, 34, 58, 1)
          ])
          // image: DecorationImage(
          //   image: AssetImage("assets/Mask group.png"),
          //   fit: BoxFit.cover,
          // ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add,color: Colors.white,),
                    label: Text("Top-up",style: GoogleFonts.figtree(color: Colors.white,fontSize: 15),),
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Total Balance",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "₹ 25,000",
              style: TextStyle(
                color: Color(0xFF16C784),
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  ),

  body: Column(
    children: [
     Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 10,top: 20,bottom: 10),
                child: Container(
                  height: 45,
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppTheme().appBarBackgroundColor,
                    border:Border.all(color: Colors.grey,width: 1) ,
                    borderRadius: BorderRadius.circular(30)

                  ),
                  child: Center(child: Text("All Categories",style: GoogleFonts.figtree(fontSize:14,fontWeight: FontWeight(400),color:Colors.white ),)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 10),
                child: Container(
                  height: 45,
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppTheme().appBarBackgroundColor,
                    border:Border.all(color: Colors.grey,width: 1) ,
                    borderRadius: BorderRadius.circular(30)

                  ),
                  child: Center(child: Text("dd-mm-yyyy",style: GoogleFonts.figtree(fontSize:14,fontWeight: FontWeight(400),color:Colors.white ),)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: MonthwiseExpenseListview().getMonthwiseExpenseListview(MonthwiseExpenseListview().transactionData)),
          ),
    ],
  ),
);
  }
}
