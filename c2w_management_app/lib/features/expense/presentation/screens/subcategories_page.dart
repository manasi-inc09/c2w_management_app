import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/edit_category.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/colorlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SubcategoriesPage extends StatefulWidget {
  final int? categoryIndex;
  final List<Map<dynamic,dynamic>>? categoryList;
  final int? subitemCount;
  const SubcategoriesPage( this.categoryIndex, this.categoryList,this.subitemCount,{super.key});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: GestureDetector(
          onTap: ()=>Navigator.pop(context),
          child: Icon(Icons.arrow_back,color:Colors.white)),
        title:Row(
            children: [
              
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: CircleAvatar(
                  backgroundColor: ColorList().colorList[widget.categoryIndex! % ColorList().colorList.length],
                  child:Text(widget.categoryList![widget.categoryIndex!]['categoryName'][0].toUpperCase(),style: GoogleFonts.figtree(fontSize: 30,fontWeight: FontWeight(600)),)
                )
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.categoryList![widget.categoryIndex!]['categoryName'],style:GoogleFonts.figtree(fontSize: 20,fontWeight: FontWeight(600),color: Colors.white)),
              Text("${widget.categoryList![widget.categoryIndex!]['subcategories_count']} Sub-Categories",style:GoogleFonts.figtree(fontSize: 15,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6)))
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>EditCategory()));
            },
            child: Text("Edit",style:GoogleFonts.figtree(color: Colors.blue,fontSize: 18,fontWeight: FontWeight(500)))),
          const SizedBox(
            width: 20,
          )
            ],
          ),
      ),
      body:Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.subitemCount,
            itemBuilder: (context,index){
          
            return Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top:30),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color:ColorList().colorList[index % ColorList().colorList.length]
                          ),
                          child: Center(child: Text(widget.categoryList![widget.categoryIndex!]['subCategories'][index][0],style: GoogleFonts.figtree(color:Colors.black,fontSize: 25,fontWeight: FontWeight(600)),)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(widget.categoryList![widget.categoryIndex!]['subCategories'][index],style: GoogleFonts.figtree(color:Colors.white,fontSize: 20,fontWeight: FontWeight(600)),),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(color: Color.fromRGBO(226, 228, 229, 0.1),),
                  
                ],
              ),
            );
          }),
          Container(
            height: 50,
            width: 400,
            decoration: BoxDecoration(
              border: Border.all(width: 1,color: Color.fromRGBO(5, 165, 255, 1)),
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(5, 165, 255, 0.1)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(5, 165, 255, 1),

                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.add)),
                  const SizedBox(
                    width: 10,
                  ),
                  Text("Add Sub-Category",style: GoogleFonts.figtree(fontSize:16,fontWeight: FontWeight(700),color: Color.fromRGBO(5, 165, 255, 1), ),)

              ],
            ),
          )
        ],
      )
    );
  }
}