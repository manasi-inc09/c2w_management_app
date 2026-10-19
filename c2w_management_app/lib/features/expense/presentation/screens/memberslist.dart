import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/members_detail_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersList extends StatefulWidget {
  const MembersList({super.key});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,

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
        "Members",
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

      //bottom: CommonFilters().getCommonFilter(filterList),
    ),
    body: SingleChildScrollView(
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
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 15,
            itemBuilder: (context,index){
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>MembersDetailList()));
                  },
                  child: Container(
                    height: 80,
                    width: 400,
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
                        Text("Sumit Katkar",style:GoogleFonts.figtree(fontSize: 15,fontWeight: FontWeight(600),color: Colors.white)),
                        Text("Member",style:GoogleFonts.figtree(fontSize: 13,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6)))
                      ],
                    ),
                    Spacer(),
                    Text("₹8560",style:GoogleFonts.figtree(fontSize:15 ,fontWeight: FontWeight(600),color: Colors.white)),
                    const SizedBox(
                      width: 10,
                    )
                      ],
                    ),
                    
                    
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            );
          })
        ],
      ),
    )
    );
  }
}