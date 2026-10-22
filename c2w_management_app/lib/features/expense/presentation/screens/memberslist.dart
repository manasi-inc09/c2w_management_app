import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/presentation/screens/members_detail_list.dart';
import 'package:c2w_management_app/features/expense/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersList extends StatefulWidget {
  const MembersList({super.key});

  @override
  State<MembersList> createState() => _MembersListState();
}

double _amount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class _MembersListState extends State<MembersList> {
  @override
  void initState() {
    super.initState();
    context.read<MembersBloc>().add(LoadMembers());
  }

  String _formatAmount(dynamic value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme().appBarBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Members",
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CommonFilters().getCategoryDateChips(context),
            const SizedBox(height: 10),
            BlocBuilder<MembersBloc, Object>(
              builder: (context, state) {
                if (state is MembersInitial || state is MembersLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  );
                }
                if (state is MembersFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Could not load members: ${state.message}',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.read<MembersBloc>().add(LoadMembers()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is! MembersLoaded) return const SizedBox.shrink();
                return BlocBuilder<ExpenseFilterBloc, ExpenseFilterInitial>(
                  builder: (context, filterState) {
                    final selection = canUseExpenseFilters()
                        ? filterState.selection
                        : const ExpenseFilterSelection();
                    final currentEmail =
                        FirebaseAuth.instance.currentUser?.email ??
                        AuthRepository.authEmail;
                    final filteredExpenses = filterExpenses(
                      state.expenses,
                      selection.copyWith(clearMember: true),
                      currentEmail: currentEmail,
                    );
                    final hasExpenseFilter =
                        selection.transactionType != 'All Transactions' ||
                        selection.category != null ||
                        selection.date != null;
                    final visibleMembers = <Map<String, dynamic>>[];
                    for (final member in state.members) {
                      final email = member['email']?.toString() ?? '';
                      if (selection.memberEmail != null &&
                          selection.memberEmail != email) {
                        continue;
                      }
                      final memberExpenses = filteredExpenses
                          .where(
                            (expense) =>
                                expense['email']?.toString().toLowerCase() ==
                                email.toLowerCase(),
                          )
                          .toList();
                      if (hasExpenseFilter && memberExpenses.isEmpty) continue;
                      final amount = memberExpenses.fold<double>(
                        0,
                        (total, expense) => total + _amount(expense['amount']),
                      );
                      visibleMembers.add({
                        ...member,
                        'totalAmount': hasExpenseFilter
                            ? amount
                            : member['totalAmount'],
                      });
                    }
                    if (visibleMembers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No members found.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visibleMembers.length,
                      itemBuilder: (context, index) {
                        final member = visibleMembers[index];
                        final name =
                            member['name']?.toString() ?? 'Unnamed member';
                        final role = member['role']?.toString() ?? 'Member';
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MembersDetailList(member: member),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                width: 400,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
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
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(
                                        "assets/image.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.figtree(
                                              fontSize: 15,
                                              fontWeight: FontWeight(600),
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            role,
                                            style: GoogleFonts.figtree(
                                              fontSize: 13,
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
                                    Text(
                                      _formatAmount(member['totalAmount']),
                                      style: GoogleFonts.figtree(
                                        fontSize: 15,
                                        fontWeight: FontWeight(600),
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
