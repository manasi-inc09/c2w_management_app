import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_history_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/floating_button.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/monthwise_individual_listview.dart';
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
        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: const Color.fromRGBO(255, 255, 255, 0.1),
              ),
              color: const Color.fromRGBO(255, 255, 255, 0.06),
            ),
            child: const Icon(Icons.search_outlined, color: Colors.white),
          ),
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
            );
            if (filteredExpenses.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return MonthwiseIndividualListview().getExpenseHistoryListview(
              filteredExpenses,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingButton.getFloatingButton(),
    );
  }
}
