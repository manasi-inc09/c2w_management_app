import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/widgets/filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

bool canUseExpenseFilters() {
  final email =
      FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail;
  return email?.startsWith('superadmin_') == true ||
      email?.startsWith('instructor_') == true;
}

Future<void> showExpenseFilters(
  BuildContext context, {
  int initialTab = 0,
}) async {
  if (!canUseExpenseFilters()) return;
  final bloc = context.read<ExpenseFilterBloc>();
  final initialSelection = bloc.state.selection;
  if (bloc.state.runtimeType == ExpenseFilterInitial) {
    bloc.add(LoadExpenseFilterOptions());
  }

  final result = await showModalBottomSheet<ExpenseFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1F2433),
    builder: (_) => BlocBuilder<ExpenseFilterBloc, ExpenseFilterInitial>(
      builder: (context, state) => _ExpenseFilterSheet(
        initialSelection: initialSelection,
        categories: state is ExpenseFilterLoaded
            ? state.categories
            : const <String>[],
        subCategories: state is ExpenseFilterLoaded
            ? state.subCategories
            : const <String, List<String>>{},
        members: state is ExpenseFilterLoaded
            ? state.members
            : const <Map<String, dynamic>>[],
        initialTab: initialTab,
        loading:
            state.runtimeType == ExpenseFilterInitial ||
            state is ExpenseFilterLoading,
        error: state is ExpenseFilterFailure ? state.message : null,
      ),
    ),
  );
  if (result != null && context.mounted) {
    bloc.add(ApplyExpenseFilters(result));
  }
}

class CommonFilters {
  PreferredSize getCommonFilter(BuildContext context) {
    if (!canUseExpenseFilters()) {
      return const PreferredSize(preferredSize: Size.zero, child: SizedBox());
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: BlocBuilder<ExpenseFilterBloc, ExpenseFilterInitial>(
          builder: (context, state) {
            final selection = state.selection;
            return Row(
              children: [
                const SizedBox(width: 20),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => showExpenseFilters(context),
                      child: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    if (selection.activeFilterCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              '${selection.activeFilterCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final label in selection.labels)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: label,
                              onTap: () => showExpenseFilters(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getCategoryDateChips(BuildContext context) {
    if (!canUseExpenseFilters()) return const SizedBox.shrink();
    return BlocBuilder<ExpenseFilterBloc, ExpenseFilterInitial>(
      builder: (context, state) {
        final selection = state.selection;
        final categoryLabel =
            selection.subCategory ?? selection.category ?? 'All Categories';
        final date = selection.date;
        final dateLabel = date == null
            ? 'dd/mm/yyyy'
            : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        return SizedBox(
          height: 65,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 10,
                  top: 20,
                  bottom: 10,
                ),
                child: _FilterChip(
                  label: categoryLabel,
                  width: 140,
                  onTap: () => showExpenseFilters(context, initialTab: 1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 20,
                  bottom: 10,
                ),
                child: _FilterChip(
                  label: dateLabel,
                  width: 130,
                  onTap: () => showExpenseFilters(context, initialTab: 3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 20,
                  bottom: 10,
                ),
                child: _FilterChip(
                  label: selection.memberName ?? 'All Members',
                  width: 140,
                  onTap: () => showExpenseFilters(context, initialTab: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final double? width;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1,
            color: const Color.fromRGBO(255, 255, 255, 0.1),
          ),
          color: const Color.fromRGBO(255, 255, 255, 0.06),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseFilterSheet extends StatefulWidget {
  final ExpenseFilterSelection initialSelection;
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final List<Map<String, dynamic>> members;
  final int initialTab;
  final bool loading;
  final String? error;

  const _ExpenseFilterSheet({
    required this.initialSelection,
    required this.categories,
    required this.subCategories,
    required this.members,
    required this.initialTab,
    required this.loading,
    required this.error,
  });

  @override
  State<_ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<_ExpenseFilterSheet> {
  late ExpenseFilterSelection _selection;
  late int _currentTab;
  String? _expandedCategory;

  static const _tabs = ['Transactions', 'Categories', 'Members', 'Date'];

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    _currentTab = widget.initialTab.clamp(0, _tabs.length - 1);
    _expandedCategory = _selection.category;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                Text(
                  'Filters & Sort',
                  style: GoogleFonts.figtree(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(
                    () => _selection = const ExpenseFilterSelection(),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Color(0xFFFF5572)),
                  ),
                ),
              ],
            ),
          ),
          if (_selection.labels.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _selection.labels.map(_buildSelectionChip).toList(),
              ),
            ),
          const Divider(height: 1, color: Colors.white24),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: ListView.builder(
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final selected = index == _currentTab;
                      return InkWell(
                        onTap: () => setState(() => _currentTab = index),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.only(left: 12),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: selected ? Colors.white10 : null,
                            border: Border(
                              left: BorderSide(
                                width: 4,
                                color: selected
                                    ? const Color(0xFF00AEFF)
                                    : Colors.transparent,
                              ),
                              bottom: const BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.white24),
                Expanded(child: _buildOptions()),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF00AEFF)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEFF),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context, _selection),
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFB000)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() {
              if (_selection.date != null &&
                  label.startsWith(
                    '${_selection.date!.day.toString().padLeft(2, '0')}/',
                  )) {
                _selection = _selection.copyWith(clearDate: true);
              } else if (_selection.memberEmail != null &&
                  label == (_selection.memberName ?? _selection.memberEmail)) {
                _selection = _selection.copyWith(clearMember: true);
              } else if (_selection.category != null &&
                  label.startsWith(_selection.category!)) {
                _selection = _selection.copyWith(
                  clearCategory: true,
                  clearSubCategory: true,
                );
                _expandedCategory = null;
              } else if (_selection.transactionType != 'All Transactions' &&
                  label == _selection.transactionType) {
                _selection = _selection.copyWith(
                  transactionType: 'All Transactions',
                );
              }
            }),
            child: const Icon(Icons.close, color: Colors.white70, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    if (widget.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00AEFF)),
      );
    }
    if (widget.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Could not load filter options: ${widget.error}',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    switch (_currentTab) {
      case 0:
        return ListView(
          children: [
            for (final type in [
              'All Transactions',
              'Recent Transactions',
              'My Transactions',
            ])
              _radioTile(
                label: type,
                selected: _selection.transactionType == type,
                onTap: () => setState(
                  () => _selection = _selection.copyWith(transactionType: type),
                ),
              ),
          ],
        );
      case 1:
        if (widget.categories.isEmpty) {
          return const Center(
            child: Text(
              'No transaction categories found.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView(
          children: [
            for (final category in widget.categories) ...[
              _radioTile(
                label: category,
                selected:
                    _selection.category == category &&
                    _selection.subCategory == null,
                trailing: widget.subCategories[category]?.isNotEmpty == true
                    ? Icon(
                        _expandedCategory == category
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white54,
                      )
                    : null,
                onTap: () => setState(() {
                  _selection = _selection.copyWith(
                    category: category,
                    clearSubCategory: true,
                  );
                  _expandedCategory = _expandedCategory == category
                      ? null
                      : category;
                }),
              ),
              if (_expandedCategory == category)
                for (final subCategory
                    in widget.subCategories[category] ?? const <String>[])
                  _radioTile(
                    label: subCategory,
                    selected:
                        _selection.category == category &&
                        _selection.subCategory == subCategory,
                    indent: 20,
                    onTap: () => setState(
                      () => _selection = _selection.copyWith(
                        category: category,
                        subCategory: subCategory,
                      ),
                    ),
                  ),
            ],
          ],
        );
      case 2:
        return ListView(
          children: [
            for (final member in widget.members)
              Builder(
                builder: (context) {
                  final name = member['name']?.toString() ?? 'Unnamed member';
                  final selected =
                      _selection.memberEmail == member['email']?.toString();
                  return _radioTile(
                    label: name,
                    selected: selected,
                    leadingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? const Color(0xFF00AEFF)
                              : Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF536D8A),
                          child: Text(
                            name.isEmpty ? 'M' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => setState(
                      () => _selection = _selection.copyWith(
                        memberEmail: member['email']?.toString(),
                        memberName: name,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      default:
        return Center(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: Text(
              _selection.date == null
                  ? 'Choose date'
                  : '${_selection.date!.day.toString().padLeft(2, '0')}/${_selection.date!.month.toString().padLeft(2, '0')}/${_selection.date!.year}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }

  Widget _radioTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Widget? trailing,
    Widget? leadingWidget,
    double indent = 0,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 12 + indent, right: 8),
      onTap: onTap,
      leading:
          leadingWidget ??
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? const Color(0xFF00AEFF) : Colors.white38,
            size: 20,
          ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: trailing,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selection.date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00AEFF),
            surface: Color(0xFF1F2433),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() => _selection = _selection.copyWith(date: date));
    }
  }
}
