import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/add_new_category.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/subcategories_page.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/colorlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCategories extends StatefulWidget {
  const ManageCategories({super.key});

  @override
  State<ManageCategories> createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCategoryBloc>().add(LoadExpenseCategories());
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddCategory() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddNewCategory()),
    );
    if (saved == true && mounted) {
      context.read<ExpenseCategoryBloc>().add(LoadExpenseCategories());
      context.read<ExpenseFilterBloc>().add(LoadExpenseFilterOptions());
    }
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

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
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
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
            ),
            onPressed: _openAddCategory,
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.white),
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
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
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
          Expanded(
            child: BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
              builder: (context, state) {
                if (state is ExpenseCategoryInitial ||
                    state is ExpenseCategoryLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
                if (state is ExpenseCategoryFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not load categories: ${state.message}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<ExpenseCategoryBloc>()
                              .add(LoadExpenseCategories()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is! ExpenseCategoryLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                final categories = state.categories.where((category) {
                  final name = category['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_query);
                }).toList();
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No categories added yet.'
                          : 'No matching categories.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final name = category['name']?.toString() ?? '';
                    final company =
                        category['company']?.toString() ??
                        'Company not assigned';
                    final subCategories =
                        (category['subCategories'] as List?)
                            ?.map((value) => value.toString())
                            .toList() ??
                        <String>[];
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                      ),
                      child: Container(
                        height: 85,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: AppTheme().appBarBackgroundColor,
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 34, 34, 34),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              height: 50,
                              width: 50,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor: ColorList().colorForIndex(index),
                                child: Text(
                                  name.isEmpty ? '?' : name[0].toUpperCase(),
                                  style: GoogleFonts.figtree(
                                    fontSize: 25,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.figtree(
                                      fontSize: 18,
                                      fontWeight: FontWeight(600),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    company,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.figtree(
                                      fontSize: 15,
                                      fontWeight: FontWeight(500),
                                      color: const Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        0.6,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${subCategories.length} Sub-Categories",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.figtree(
                                      fontSize: 15,
                                      fontWeight: FontWeight(400),
                                      color: const Color.fromRGBO(
                                        255,
                                        255,
                                        255,
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubcategoriesPage(
                                      category: category,
                                      categoryIndex: index,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  context.read<ExpenseCategoryBloc>().add(
                                    LoadExpenseCategories(),
                                  );
                                  context.read<ExpenseFilterBloc>().add(
                                    LoadExpenseFilterOptions(),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
