import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionDetails extends StatefulWidget {
  const TransactionDetails({super.key});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white)),
        title: Text("Transactions Details",style:GoogleFonts.figtree(color: Colors.white,fontSize: 20,fontWeight: FontWeight(600))),
      ),
      
      body:Center(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape:BoxShape.circle,
                color: Color.fromRGBO(255, 194, 187, 1)
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Anuja Shinde",style: GoogleFonts.figtree(color: Colors.white,fontSize: 22,fontWeight: FontWeight(500)),),
            Text("₹86.00",style: GoogleFonts.poppins(color: Color.fromRGBO(255, 77, 106, 1),fontSize: 32,fontWeight: FontWeight(600)),),
            SizedBox(
                    height: 20,
                  ),
            Container(
              padding: EdgeInsets.all(15),
              height: 450,
              width: 400,
              decoration: BoxDecoration(
                color: AppTheme().appBarBackgroundColor,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text("Date & Time",style: GoogleFonts.figtree(fontSize: 14,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  SizedBox(
                    height: 10,
                  ),
                  Text("14 Dec 2026, 12:50 AM",style: GoogleFonts.figtree(fontSize: 16,fontWeight: FontWeight(500),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Category",style: GoogleFonts.figtree(fontSize: 14,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Event",style: GoogleFonts.figtree(fontSize: 16,fontWeight: FontWeight(500),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  Divider(color: Color.fromRGBO(47, 44, 44, 0.8),),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Sub-category",style: GoogleFonts.figtree(fontSize: 14,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  SizedBox(
                    height: 10,
                  ),
                  Text("CPL 2026",style: GoogleFonts.figtree(fontSize: 16,fontWeight: FontWeight(500),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Details",style: GoogleFonts.figtree(fontSize: 14,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Stationery, Notebook, Pen",style: GoogleFonts.figtree(fontSize: 16,fontWeight: FontWeight(500),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  Divider(color: Color.fromRGBO(47, 44, 44, 0.8)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Photo Attachments",style: GoogleFonts.figtree(fontSize: 14,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6))),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                ],
              ),
            
            ),
            SizedBox(
                    height: 20,
                  ),
            SettleButton().getSettleButton(context,"Settle")
          ],
        ),
      )
    );
  }
}