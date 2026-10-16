import 'package:c2w_management_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettleButton{
  Widget getSettleButton(BuildContext context,String text,{Widget? container}){
    return Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color:AppTheme().appBarBackgroundColor,
                //border: Border.all(width: 0.5,color: Colors.grey)
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap:() {
                      if(container != null){
                        showModalBottomSheet(context: context, builder: (BuildContext context){
                          return container;
                        });
                      }else{

                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      height: 55,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(child: Text("$text",style:GoogleFonts.figtree(color: Colors.white,fontSize: 16,fontWeight: FontWeight(600)))) 
                    ,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
              
            );
  }
}