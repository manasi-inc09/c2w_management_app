import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCategory extends StatefulWidget {
  final Map<String, dynamic> category;

  const EditCategory({super.key, required this.category});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  late final TextEditingController _categoryController;
  late final List<TextEditingController> _subCategoryControllers;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(
      text: widget.category['name']?.toString() ?? '',
    );
    final subCategories = widget.category['subCategories'];
    _subCategoryControllers = subCategories is List
        ? subCategories
              .map((value) => TextEditingController(text: value.toString()))
              .toList()
        : [];
  }

  void _save() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a category name.')));
      return;
    }
    final id = widget.category['id']?.toString();
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not identify this category.')),
      );
      return;
    }
    context.read<ExpenseCategoryBloc>().add(
      SaveExpenseCategory(
        id: id,
        name: name,
        subCategories: _subCategoryControllers
            .map((controller) => controller.text.trim())
            .where((value) => value.isNotEmpty)
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    for (final controller in _subCategoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!canManageExpenseCategories()) {
      return const Scaffold(
        body: Center(
          child: Text('Only SuperAdmin or Instructor can manage categories.'),
        ),
      );
    }

    return BlocListener<ExpenseCategoryBloc, ExpenseCategoryState>(
      listener: (context, state) {
        if (state is ExpenseCategorySaved) {
          context.read<ExpenseFilterBloc>().add(LoadExpenseFilterOptions());
          Navigator.pop(context, true);
        } else if (state is ExpenseCategoryFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme().bodyBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme().appBarBackgroundColor,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            "Edit Category",
            style: GoogleFonts.figtree(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Category Title'),
                const SizedBox(height: 10),
                TextField(
                  controller: _categoryController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight(400),
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Sub-Categories'),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subCategoryControllers.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: _subCategoryControllers[index],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        prefixText: "${index + 1}. ",
                        prefixStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        hintText: "Enter Sub-Category ${index + 1}",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(
                    () => _subCategoryControllers.add(TextEditingController()),
                  ),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: const Color.fromRGBO(5, 165, 255, 1),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(5, 165, 255, 0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(5, 165, 255, 1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Add Sub-Category",
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(5, 165, 255, 1),
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
        bottomNavigationBar:
            BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
              builder: (context, state) => SettleButton().getSettleButton(
                context,
                "Save Changes",
                isLoading: state is ExpenseCategorySaving,
                onTap: state is ExpenseCategorySaving ? null : _save,
              ),
            ),
      ),
    );
  }

  Widget _sectionTitle(String value) => Text(
    value,
    style: GoogleFonts.figtree(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color.fromRGBO(255, 255, 255, 0.6),
    ),
  );
}
