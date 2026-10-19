import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/subcategories_page.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/colorlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  List<Map> categoryList=[{"categoryName":"Food",
                            "subcategories_count":1,
                            "subCategories":["marriage","CPL",]
                            },
                            {
                              "categoryName":"Events",
                            "subcategories_count":0,
                            "subCategories":[]
                            },
                            {"categoryName":"Food",
                            "subcategories_count":1,
                            "subCategories":["marriage"]
                            },
                            {
                              "categoryName":"Events",
                            "subcategories_count":0,
                            "subCategories":[]
                            }];


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white)),
        title: Text(
          "Manage Categories",
          style: GoogleFonts.figtree(
            fontSize: 20,
            fontWeight: FontWeight(600),
            color: Colors.white,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
            ),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>AddNewCategory()));
            },
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.white),
                Text(
                  "Add",
                  style: GoogleFonts.figtree(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight(500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              style: TextStyle(color: Colors.white),

              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme().appBarBackgroundColor,
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: Colors.white,
                ),

                hintText: "Search by name",
                hintStyle: const TextStyle(color: Colors.white54),

                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 43, 42, 42),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color.fromARGB(255, 34, 34, 34),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          
          ListView.builder(
            shrinkWrap: true,
            itemCount: categoryList.length,
            itemBuilder: (context,index){
            return Padding(
              padding: const EdgeInsets.only(left:15.0,right: 15,top: 10,),
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppTheme().appBarBackgroundColor,
                  border: Border.all(width: 1,color:Color.fromARGB(255, 34, 34, 34)),
                  borderRadius: BorderRadius.circular(10)
                ),
                child:Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          backgroundColor: ColorList().colorList[index % ColorList().colorList.length],
                          child:Text(categoryList[index]['categoryName'][0].toUpperCase(),style: GoogleFonts.figtree(fontSize: 30,fontWeight: FontWeight(600)),)
                        )
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryList[index]['categoryName'],style:GoogleFonts.figtree(fontSize: 20,fontWeight: FontWeight(600),color: Colors.white)),
                      Text("${categoryList[index]['subcategories_count']} Sub-Categories",style:GoogleFonts.figtree(fontSize: 15,fontWeight: FontWeight(400),color: Color.fromRGBO(255, 255, 255, 0.6)))
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SubcategoriesPage(index,categoryList,categoryList[index]['subCategories'].length)));
                      setState(() {
                        
                      });
                    },
                    child: Icon(Icons.arrow_forward,color: Colors.white,)),
                  const SizedBox(
                    width: 10,
                  )
                    ],
                  ),
              ),
            );
          })
        ],
      ),
    );
  }
}
