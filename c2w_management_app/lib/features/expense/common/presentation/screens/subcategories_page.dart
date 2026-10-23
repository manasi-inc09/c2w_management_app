import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/edit_category.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/colorlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SubcategoriesPage extends StatelessWidget {
  final Map<String, dynamic> category;
  final int categoryIndex;

  const SubcategoriesPage({
    super.key,
    required this.category,
    required this.categoryIndex,
  });

  List<String> get _subCategories {
    final values = category['subCategories'];
    return values is List
        ? values.map((value) => value.toString()).toList()
        : [];
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditCategory(category: category)),
    );
    if (saved == true && context.mounted) {
      context.read<ExpenseCategoryBloc>().add(LoadExpenseCategories());
      context.read<ExpenseFilterBloc>().add(LoadExpenseFilterOptions());
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = category['name']?.toString() ?? '';
    final subCategories = _subCategories;

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: ColorList()
                    .colorList[categoryIndex % ColorList().colorList.length],
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: GoogleFonts.figtree(
                    fontSize: 30,
                    fontWeight: FontWeight(600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      fontSize: 20,
                      fontWeight: FontWeight(600),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${subCategories.length} Sub-Categories",
                    style: GoogleFonts.figtree(
                      fontSize: 15,
                      fontWeight: FontWeight(400),
                      color: const Color.fromRGBO(255, 255, 255, 0.6),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: canManageExpenseCategories()
                  ? () => _edit(context)
                  : null,
              child: Text(
                "Edit",
                style: GoogleFonts.figtree(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight(500),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: subCategories.isEmpty
                ? const Center(
                    child: Text(
                      'No sub-categories.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      final value = subCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 30,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              width: MediaQuery.sizeOf(context).width,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          ColorList().colorList[index %
                                              ColorList().colorList.length],
                                    ),
                                    child: Center(
                                      child: Text(
                                        value.isEmpty
                                            ? '?'
                                            : value[0].toUpperCase(),
                                        style: GoogleFonts.figtree(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontWeight: FontWeight(600),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      value,
                                      style: GoogleFonts.figtree(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight(600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                              color: Color.fromRGBO(226, 228, 229, 0.1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (canManageExpenseCategories())
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit),
                  label: const Text("Add Sub-Category"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
