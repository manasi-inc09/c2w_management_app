import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewCategory extends StatefulWidget {
  const AddNewCategory({super.key});

  @override
  State<AddNewCategory> createState() => _AddNewCategoryState();
}

class _AddNewCategoryState extends State<AddNewCategory> {
   TextEditingController? categoryController;

  List<TextEditingController> subCategoryControllers = [];

  @override
  void initState() {
    super.initState();

   
  }

  // Add new TextField
  void addSubCategory() {
    setState(() {
      subCategoryControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    //categoryController.dispose();

    for (var controller in subCategoryControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,

      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,

        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),

        title: Text(
          "New Category",
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // CATEGORY TITLE

              Text(
                "Category Title",
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight(400),
                ),
                controller: categoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Color.fromRGBO(31, 34, 49, 1),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SUBCATEGORIES
              Text(
                "Sub-Categories",
                style: GoogleFonts.figtree(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                ),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),

                itemCount: subCategoryControllers.length,

                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      TextField(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight(400),
                        ),
                        
                        controller: subCategoryControllers[index],

                        decoration: InputDecoration(
                          prefixText: "${index + 1}. ",
                          prefixStyle:TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight(400),
                        ) ,
                          hintText: "Enter Sub-Category ${index + 1}",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 10),
                    ],
                  );
                },
              ),

              // ADD SUBCATEGORY BUTTON
              GestureDetector(
                onTap: addSubCategory,

                child: Container(
                  height: 50,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(5, 165, 255, 1),
                    ),

                    borderRadius: BorderRadius.circular(10),

                    color: Color.fromRGBO(5, 165, 255, 0.1),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        height: 25,
                        width: 25,

                        decoration: BoxDecoration(
                          color: Color.fromRGBO(5, 165, 255, 1),
                          shape: BoxShape.circle,
                        ),

                        child: Icon(Icons.add),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "Add Sub-Category",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(5, 165, 255, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 25),

            ],
          ),
        ),
      ),
    bottomNavigationBar: SettleButton().getSettleButton(context,"Add Category"),  
    );
  }
}