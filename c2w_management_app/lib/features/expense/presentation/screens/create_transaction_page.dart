import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/settle_button.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_event.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_state.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewTransaction extends StatefulWidget {
  const CreateNewTransaction({super.key});

  @override
  State<CreateNewTransaction> createState() => _CreateNewTransactionState();
}

class _CreateNewTransactionState extends State<CreateNewTransaction> {
  XFile? file;
  String? url;
  DateTime? selectedDate;
  Future<void> getdate()async{
    DateTime? showDate=await showDatePicker(context: context, initialDate: selectedDate??DateTime.now(),firstDate: DateTime(2020), lastDate: DateTime(2030));
    if(showDate!=null){
      setState(() {
        selectedDate=showDate;
      });
    }
  }
  Future<void> getImage()async{
    ImagePicker imagePicker=ImagePicker();
    final XFile? image =await imagePicker.pickImage(source: ImageSource.gallery);
    int fileSize = await image!.length();

    if (fileSize > 60 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image size must be less than 60 MB"),
        ),
      );
      return;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Image successfully uploaded",style: TextStyle(color: Colors.white),),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      
      file=image;
    
    });
  }
  String selectedOption = "Option 1";

  String? selectedCategory;
  String? selectedSubCategory;

  final List<String> categories = [
    "Food",
    "Shopping",
    "Travel",
    "Education",
    "Health",
    "Other",
  ];
  TextEditingController dateController=TextEditingController();
  TextEditingController amountController=TextEditingController();
  TextEditingController detailsController=TextEditingController();
  //TextEditingController selectedSubCategory=TextEditingController();
  //TextEditingController selectedSubCategory=TextEditingController();
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
        title: Text(
          "Transactions Details",
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight(600),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: dateController,
                cursorColor: Colors.white,
                style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6),fontSize: 20,fontWeight: FontWeight(400)),
        
                decoration: InputDecoration(
                  hintText: (selectedDate==null)?"Select Date":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  suffixIcon: GestureDetector(
                    onTap: (){
                      getdate();
                    },
                    child: Icon(Icons.calendar_month_outlined)),
                  suffixIconColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(31, 34, 49, 1),
                      width: 1,
                    ),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Amount",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: amountController,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
        
                decoration: InputDecoration(
                  hintText: "Type here your Expense Amount",
        
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(31, 34, 49, 1),
                      width: 1,
                    ),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Expense Source",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  buildRadioBox(title: "Self Paid", value: "Option 1"),
                  const SizedBox(width: 12),
                  (loginAs=="Instructor".toUpperCase())?buildRadioBox(title: "Wallet", value: "Option 2"):SizedBox(),
                ],
              ),
              const SizedBox(height: 5),
              (selectedOption == "Option 2") ? showWalletbalance() : SizedBox(),
              const SizedBox(height: 20),
              Text(
                "Transaction Details",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: detailsController,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
        
                decoration: InputDecoration(
                  hintText: "e.g.stationery, notebook, pen",
        
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(31, 34, 49, 1),
                      width: 1,
                    ),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Category",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                
                initialValue: selectedCategory,
        
                dropdownColor: Color(0xFF0B0D1C),
        
                icon: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 30,
                  ),
                ),
        
                style: TextStyle(color: Colors.white, fontSize: 18),
        
                decoration: InputDecoration(
                  hint: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                        "Select category",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                  ),
        
                  hintStyle: TextStyle(color: Color(0xFF454858), fontSize: 18),
        
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
        
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF292C3E), width: 1),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00AEFF), width: 1.5),
                  ),
                ),
        
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
        
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Sub-Category",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
        
                dropdownColor: Color(0xFF0B0D1C),
        
                icon: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 30,
                  ),
                ),
        
                style: TextStyle(color: Colors.white, fontSize: 18),
        
                decoration: InputDecoration(
        
                  hint: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                        "Select category",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                  ),
        
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
        
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF292C3E), width: 1),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00AEFF), width: 1.5),
                  ),
                ),
        
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
        
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Attach Receipt",
                style: GoogleFonts.figtree(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight(400),
                ),
              ),
              const SizedBox(height: 5),
              DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        color: const Color(0xFF292C3E),
        strokeWidth: 2,
        dashPattern: const [8, 6],
        padding: EdgeInsets.zero,
      ),

      child: Container(
        width: double.infinity,
        height: 250,

        decoration: BoxDecoration(
          color: const Color(0xFF080B1B),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Image Icon
            const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF454858),
              size: 50,
            ),

            const SizedBox(height: 25),

            // Upload Button
            ElevatedButton(
              onPressed: () {
                getImage();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF292C3E),
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              child: const Text(
                "Upload image",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Supported formats
            const Text(
              "Supported formats: JPG, PNG | Max.60 MB",
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
            ],
          ),
        ),
        
      ),
      bottomNavigationBar:
    BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
  listener: (context, state) {
    if (state is CreateExpenseSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }

    if (state is CreateExpenseFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    return SettleButton().getSettleButton(
      context,
      'Create',
      isLoading: state is CreateExpenseLoading,
      onTap: state is CreateExpenseLoading
          ? null
          : submitExpense,
    );
  },
),
    );
  }

  Widget buildRadioBox({required String title, required String value}) {
    String localSelectedOption = selectedOption;
    bool isSelected = localSelectedOption == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            localSelectedOption = value;
          });
          setState(() {
            selectedOption = value;
            if (value == "Option 2") {
              showWalletbalance();
            } // Update main page state
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(
              7,
              10,
              27,
              1,
            ), // Dark container background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue
                  : Colors
                        .grey
                        .shade800, // Blue border if selected, grey otherwise
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Custom Radio Circle Indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showWalletbalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(252, 174, 16, 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text(
            "Available Balance: ",
            style: TextStyle(color: Colors.grey, fontSize: 17),
          ),

          Text(
            "10,000",
            style: TextStyle(
              color: Color.fromRGBO(28, 205, 128, 1),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void submitExpense() {
  // 1. Validate expense date
  if (selectedDate == null) {
    showMessage('Please select an expense date.');
    return;
  }

  // 2. Validate amount
  final double? amount =
      double.tryParse(amountController.text.trim());

  if (amount == null || amount <= 0) {
    showMessage('Please enter a valid amount.');
    return;
  }

  // 3. Validate transaction details
  if (detailsController.text.trim().isEmpty) {
    showMessage('Please enter transaction details.');
    return;
  }

  // 4. Validate category
  if (selectedCategory == null) {
    showMessage('Please select a category.');
    return;
  }

  // 6. Determine expense source
  final String source =
      selectedOption == 'Option 2' ? 'Wallet' : 'Self Paid';

  // 7. Create the Expense object
  final expense = Expense(
    expenseDate: selectedDate!,
    amount: amount,
    source: source,
    description: detailsController.text.trim(),
    category: selectedCategory!,
    subCategory: selectedSubCategory!,
    receiptLocalPath: file?.path,
  );

  // 8. Send the expense to the BLoC
  context.read<CreateExpenseBloc>().add(
        SubmitExpenseEvent(expense),
      );
}

void showMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

}

