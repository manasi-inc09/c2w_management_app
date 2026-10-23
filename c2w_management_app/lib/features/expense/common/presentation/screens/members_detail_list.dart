import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/bottomsheet_settle.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/monthwise_individual_listview.dart';
import 'package:c2w_management_app/features/expense/presentation/utils/reload_after_event.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/settle_button.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersDetailList extends StatefulWidget {
  final Map<String, dynamic> member;

  const MembersDetailList({super.key, required this.member});

  @override
  State<MembersDetailList> createState() => _MembersDetailListState();
}

class _MembersDetailListState extends State<MembersDetailList> {
  Future<void> _refreshMemberDetails() {
    final bloc = context.read<MemberDetailsBloc>();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadMemberDetails(widget.member)),
      isComplete: (state) =>
          state is MemberDetailsLoaded || state is MemberDetailsFailure,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<MemberDetailsBloc>().add(LoadMemberDetails(widget.member));
  }

  double _amount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$formatted';
  }

  double _total(List<Map<String, dynamic>> expenses) {
    return expenses.fold<double>(
      0,
      (runningTotal, expense) => runningTotal + _amount(expense['amount']),
    );
  }

  double _settled(List<Map<String, dynamic>> expenses) {
    return expenses
        .where(
          (expense) => expense['status']?.toString().toLowerCase() == 'settled',
        )
        .fold<double>(
          0,
          (runningTotal, expense) => runningTotal + _amount(expense['amount']),
        );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.member['name']?.toString() ?? 'Unnamed member';
    final role = widget.member['role']?.toString() ?? 'Member';
    final authEmail =
        FirebaseAuth.instance.currentUser?.email ??
        AuthRepository.authEmail ??
        '';
    final canSettle =
        authEmail.contains('instructor_') || authEmail.contains('superadmin_');

    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_sharp, color: Colors.white),
        ),
        backgroundColor: AppTheme().appBarBackgroundColor,
        title: BlocBuilder<MemberDetailsBloc, Object>(
          builder: (context, state) {
            var total = _amount(widget.member['totalAmount']);
            var settled = 0.0;
            if (state is MemberDetailsLoaded) {
              final selection = canUseExpenseFilters()
                  ? context.watch<ExpenseFilterBloc>().state.selection
                  : const ExpenseFilterSelection();
              final expenses = filterExpenses(
                state.expenses,
                selection,
                currentEmail: authEmail,
              );
              total = _total(expenses);
              settled = _settled(expenses);
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: AppTheme().appBarBackgroundColor,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset("assets/image.png", fit: BoxFit.cover),
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
                            fontWeight: FontWeight(400),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 15,
                            fontWeight: FontWeight(400),
                            color: const Color.fromRGBO(255, 255, 255, 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(total),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight(500),
                          color: Colors.white,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Settled: ",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(
                              text: _formatAmount(settled),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            );
          },
        ),
      ),
      body: BlocBuilder<MemberDetailsBloc, Object>(
        builder: (context, state) {
          if (state is MemberDetailsInitial || state is MemberDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
            );
          }
          if (state is MemberDetailsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load member transactions: ${state.message}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () => context.read<MemberDetailsBloc>().add(
                        LoadMemberDetails(widget.member),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! MemberDetailsLoaded) return const SizedBox.shrink();

          final selection = canUseExpenseFilters()
              ? context.watch<ExpenseFilterBloc>().state.selection
              : const ExpenseFilterSelection();
          final expenses = filterExpenses(
            state.expenses,
            selection,
            currentEmail: authEmail,
          );

          return RefreshIndicator(
            onRefresh: _refreshMemberDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  CommonFilters().getCategoryDateChips(context),
                  const SizedBox(height: 10),
                  expenses.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No transactions for this member.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : MonthwiseIndividualListview().getExpenseHistoryListview(
                          expenses,
                          shrinkWrap: true,
                        ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SettleButton().getSettleButton(
        context,
        canSettle ? "Settle" : "Add Transaction",
        container: BottomsheetSettle().getBottomSheetOpen(widget.member),
      ),
    );
  }
}
