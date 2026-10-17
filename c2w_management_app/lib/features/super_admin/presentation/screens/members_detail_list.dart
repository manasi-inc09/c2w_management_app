import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:c2w_management_app/features/super_admin/presentation/screens/individual_expenses.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool isSettled=false;
class MembersDetailList extends StatefulWidget {
  const MembersDetailList({super.key});

  @override
  State<MembersDetailList> createState() => _MembersDetailListState();
}

class _MembersDetailListState extends State<MembersDetailList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_sharp,color: Colors.white,)),
        backgroundColor: AppTheme().appBarBackgroundColor,
        title: Container(
                  // height: 80,
                  // width: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color:AppTheme().appBarBackgroundColor
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1,color: Colors.white)
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset("assets/image.png",fit: BoxFit.cover,)
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sumit Katkar",style:GoogleFonts.figtree(fontSize: 18,fontWeight: FontWeight(400),color: Colors.white)),
                      Text("Member",style:GoogleFonts.figtree(fontSize: 15,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6)))
                    ],
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Text("₹8560",style:GoogleFonts.poppins(fontSize:18 ,fontWeight: FontWeight(500),color: Colors.white)),
                      RichText(
                                text: TextSpan(
                                  text: "Settled: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "₹ 0",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
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
                  const SizedBox(
                    width: 10,
                  )
                    ],
                  ),
                  
                  
                ),
      ),
      body:SingleChildScrollView(
      child: Column(
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
          MonthwiseIndividualListview().getMonthwiseExpenseListview(transactionData),
          
        ],
      ),
    ),
    bottomNavigationBar: (isSettled==true)?null:SettleButton().getSettleButton(context,(loginAs=="INSTRUCTOR"||loginAs=="SUPERADMIN")?"Settle":"Add Transaction",container: BottomsheetSettle().getBottomSheetOpen()),
    );
  }
}