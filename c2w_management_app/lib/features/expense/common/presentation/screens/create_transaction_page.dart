import 'dart:io';

import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/settle_button.dart';
import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_bloc.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_event.dart';
import 'package:c2w_management_app/features/expense/teamlead/presentation/teamlead_expense_add_bloc/teamlead_expense_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewTransaction extends StatefulWidget {
  final Map<String, dynamic>? expense;

  const CreateNewTransaction({super.key, this.expense});

  @override
  State<CreateNewTransaction> createState() => _CreateNewTransactionState();
}

class _CreateNewTransactionState extends State<CreateNewTransaction> {
  XFile? file;
  String? url;
  DateTime? selectedDate;
  Future<void> getdate() async {
    final today = DateTime.now();
    DateTime? showDate = await showDatePicker(
      context: context,
      initialDate: selectedDate != null && !selectedDate!.isAfter(today)
          ? selectedDate!
          : today,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (showDate != null) {
      setState(() {
        selectedDate = showDate;
        dateController.text = _formatDate(showDate);
      });
    }
  }

  Future<void> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final fileSize = await image.length();

    if (fileSize > 60 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image size must be less than 60 MB")),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      file = image;
    });
  }

  String selectedOption = "Option 1";

  String? selectedCategory;
  String? selectedSubCategory;

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  String? existingReceiptUrl;
  bool get _isEditing => widget.expense != null;
  //TextEditingController selectedSubCategory=TextEditingController();
  //TextEditingController selectedSubCategory=TextEditingController();
  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    selectedDate = expense == null
        ? DateTime.now()
        : _readExpenseDate(expense['expenseDate']) ?? DateTime.now();
    dateController.text = _formatDate(selectedDate!);
    if (expense != null) {
      amountController.text = expense['amount']?.toString() ?? '';
      detailsController.text = expense['description']?.toString() ?? '';
      selectedCategory = expense['category']?.toString();
      selectedSubCategory = expense['subCategory']?.toString();
      final source = expense['source']?.toString().toLowerCase();
      selectedOption = switch (source) {
        'wallet' => 'Option 2',
        'prepaid' => 'Option 3',
        _ => 'Option 1',
      };
      existingReceiptUrl = expense['receiptUrl']?.toString();
    }
    context.read<ExpenseCategoryBloc>().add(LoadExpenseCategories());
  }

  DateTime? _readExpenseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void dispose() {
    dateController.dispose();
    amountController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = context.watch<ExpenseCategoryBloc>().state;
    final availableCategories = categoryState is ExpenseCategoryLoaded
        ? categoryState.categories
        : <Map<String, dynamic>>[];
    final categoryNames = availableCategories
        .map((category) => category['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    final selectedCategoryValue = categoryNames.contains(selectedCategory)
        ? selectedCategory
        : null;
    Map<String, dynamic>? selectedCategoryData;
    for (final category in availableCategories) {
      if (category['name'] == selectedCategoryValue) {
        selectedCategoryData = category;
        break;
      }
    }
    final subCategoryValues = selectedCategoryData?['subCategories'] is List
        ? (selectedCategoryData!['subCategories'] as List)
              .map((value) => value.toString())
              .toList()
        : <String>[];
    final selectedSubCategoryValue =
        subCategoryValues.contains(selectedSubCategory)
        ? selectedSubCategory
        : null;

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
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
                readOnly: true,
                onTap: getdate,
                cursorColor: Colors.white,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  fontSize: 20,
                  fontWeight: FontWeight(400),
                ),

                decoration: InputDecoration(
                  hintText: "Select Date",
                  suffixIcon: GestureDetector(
                    onTap: getdate,
                    child: Icon(Icons.calendar_month_outlined),
                  ),
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
                  const SizedBox(width: 10),
                  buildRadioBox(title: "Prepaid", value: "Option 3"),
                  // const SizedBox(width: 12),
                  // (AuthRepository.authEmail?.startsWith("instructor_") ?? false)
                  //     ? buildRadioBox(title: "Wallet", value: "Option 2")
                  //     : const SizedBox(),
                ],
              ),
              if (selectedOption == "Option 3") ...[
                const SizedBox(height: 8),
                const Text(
                  "Select Prepaid if you have already paid this expense.",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
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
              if (categoryNames.isNotEmpty) ...[
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
                  initialValue: selectedCategoryValue,
                  dropdownColor: const Color(0xFF0B0D1C),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 30,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: const InputDecoration(
                    hint: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select category",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                    hintStyle: TextStyle(
                      color: Color(0xFF454858),
                      fontSize: 18,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color(0xFF292C3E),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color(0xFF00AEFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: categoryNames
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubCategory = null;
                    });
                  },
                ),
              ],
              if (subCategoryValues.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  "Sub-Category",
                  style: GoogleFonts.figtree(
                    color: const Color.fromRGBO(255, 255, 255, 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: selectedSubCategoryValue,

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
                        "Select sub-category",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF292C3E),
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF00AEFF),
                        width: 1.5,
                      ),
                    ),
                  ),

                  items: subCategoryValues.map((subCategory) {
                    return DropdownMenuItem<String>(
                      value: subCategory,
                      child: Text(subCategory),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedSubCategory = value;
                    });
                  },
                ),
              ],
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

                  child: file != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(file!.path),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Center(
                                child: Text(
                                  'Could not preview the selected receipt.',
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: ElevatedButton.icon(
                                onPressed: getImage,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Change image'),
                              ),
                            ),
                          ],
                        )
                      : (existingReceiptUrl?.isNotEmpty ?? false)
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              existingReceiptUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Center(
                                child: Text(
                                  'Could not load the current receipt.',
                                  style: TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: ElevatedButton.icon(
                                onPressed: getImage,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Change image'),
                              ),
                            ),
                          ],
                        )
                      : Column(
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
                                style: TextStyle(fontSize: 14),
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
      bottomNavigationBar: BlocConsumer<CreateExpenseBloc, CreateExpenseState>(
        listener: (context, state) {
          if (state is CreateExpenseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Transaction updated successfully!'
                      : 'Expense created successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context, true);
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
            _isEditing ? 'Update' : 'Create',
            isLoading: state is CreateExpenseLoading,
            onTap: state is CreateExpenseLoading ? null : submitExpense,
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
    if (selectedDate == null) {
      showMessage('Please select an expense date.');
      return;
    }

    final double? amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showMessage('Please enter a valid amount.');
      return;
    }

    if (detailsController.text.trim().isEmpty) {
      showMessage('Please enter transaction details.');
      return;
    }

    final categoryState = context.read<ExpenseCategoryBloc>().state;
    if (categoryState is ExpenseCategoryInitial ||
        categoryState is ExpenseCategoryLoading) {
      showMessage('Please wait while categories are loading.');
      return;
    }
    if (categoryState is ExpenseCategoryFailure) {
      showMessage('Could not load categories: ${categoryState.message}');
      return;
    }

    final availableCategories = categoryState is ExpenseCategoryLoaded
        ? categoryState.categories
        : <Map<String, dynamic>>[];
    final categoryNames = availableCategories
        .map((category) => category['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    final selectedCategoryValue = categoryNames.contains(selectedCategory)
        ? selectedCategory
        : null;
    if (categoryNames.isNotEmpty && selectedCategoryValue == null) {
      showMessage('Please select a category.');
      return;
    }
    Map<String, dynamic>? selectedCategoryData;
    for (final category in availableCategories) {
      if (category['name']?.toString() == selectedCategoryValue) {
        selectedCategoryData = category;
        break;
      }
    }
    final subCategoryValues = selectedCategoryData?['subCategories'] is List
        ? (selectedCategoryData!['subCategories'] as List)
              .map((value) => value.toString())
              .toList()
        : <String>[];
    final selectedSubCategoryValue =
        subCategoryValues.contains(selectedSubCategory)
        ? selectedSubCategory
        : null;
    if (file == null && (existingReceiptUrl?.isEmpty ?? true)) {
      showMessage('Please attach a receipt.');
      return;
    }

    final String source = switch (selectedOption) {
      'Option 2' => 'Wallet',
      'Option 3' => 'Prepaid',
      _ => 'Self Paid',
    };

    String? categoryCompany = widget.expense?['company']?.toString();
    if (categoryState is ExpenseCategoryLoaded) {
      for (final category in categoryState.categories) {
        if (category['name']?.toString() == selectedCategoryValue) {
          categoryCompany = category['company']?.toString() ?? categoryCompany;
          break;
        }
      }
    }

    final expense = Expense(
      expenseDate: selectedDate!,
      amount: amount,
      source: source,
      description: detailsController.text.trim(),
      category: selectedCategoryValue ?? '',
      company: categoryCompany,
      subCategory: selectedSubCategoryValue ?? '',
      receiptLocalPath: file?.path,
    );

    if (_isEditing) {
      final expenseId = widget.expense?['id']?.toString();
      if (expenseId == null || expenseId.isEmpty) {
        showMessage(
          'This transaction cannot be updated because its ID is missing.',
        );
        return;
      }
      context.read<CreateExpenseBloc>().add(
        UpdateExpenseEvent(
          expenseId: expenseId,
          expense: expense,
          existingReceiptUrl: existingReceiptUrl,
        ),
      );
      return;
    }
    context.read<CreateExpenseBloc>().add(SubmitExpenseEvent(expense));
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
