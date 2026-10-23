import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_history_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/floating_button.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/presentation/utils/reload_after_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAllExpenses extends StatefulWidget {
  const ViewAllExpenses({super.key});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _matchesExpenseSearch(Map<String, dynamic> expense) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      expense['claimantName'],
      expense['description'],
      expense['category'],
      expense['subCategory'],
      expense['source'],
      expense['amount'],
      expense['email'],
    ].any((value) => value?.toString().toLowerCase().contains(query) ?? false);
  }

  Future<void> _refreshExpenses() {
    final bloc = context.read<ExpenseHistoryBloc>();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadAllExpenses()),
      isComplete: (state) =>
          state is ExpenseHistoryLoaded || state is ExpenseHistoryFailure,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ExpenseHistoryBloc>().add(LoadAllExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().appBarBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Search transactions',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          IconButton(
            onPressed: _isSearching
                ? _toggleSearch
                : () => setState(() => _isSearching = true),
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_outlined,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 255, 255, 0.06),
              shape: const CircleBorder(
                side: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1)),
              ),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          const SizedBox(width: 15),
        ],
        bottom: CommonFilters().getCommonFilter(context),
      ),
      body: BlocBuilder<ExpenseHistoryBloc, ExpenseHistoryState>(
        builder: (context, state) {
          if (state is ExpenseHistoryInitial ||
              state is ExpenseHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          }
          if (state is ExpenseHistoryFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load transactions: ${state.message}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is ExpenseHistoryLoaded) {
            final selection = canUseExpenseFilters()
                ? context.watch<ExpenseFilterBloc>().state.selection
                : const ExpenseFilterSelection();
            final filteredExpenses = filterExpenses(
              state.expenses,
              selection,
              currentEmail:
                  FirebaseAuth.instance.currentUser?.email ??
                  AuthRepository.authEmail,
            ).where(_matchesExpenseSearch).toList();
            if (filteredExpenses.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshExpenses,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'No transactions yet.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshExpenses,
              child: MonthwiseIndividualListview().getExpenseHistoryListview(
                filteredExpenses,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingButton.getFloatingButton(),
    );
  }
}
