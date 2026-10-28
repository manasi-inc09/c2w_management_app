import 'dart:developer';

import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_admin_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_filter_bloc.dart';
import 'package:c2w_management_app/features/expense/common/presentation/screens/members_detail_list.dart';
import 'package:c2w_management_app/features/expense/common/presentation/widgets/common_filters.dart';
import 'package:c2w_management_app/features/expense/common/presentation/utils/reload_after_event.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshMembers() {
    final bloc = context.read<MembersBloc>();
    return reloadAfterEvent(
      states: bloc.stream,
      dispatch: () => bloc.add(LoadMembers()),
      isComplete: (state) => state is MembersLoaded || state is MembersFailure,
    );
  }

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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool _matchesSearch(Map<String, dynamic> member) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      member['name'],
      member['email'],
      member['role'],
      member['mobile'],
    ].any((value) => value?.toString().toLowerCase().contains(query) ?? false);
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Search members',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Members",
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
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMembers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        if (!_matchesSearch(member)) continue;
                        log("++++++++++$state.members".toString());
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
                        if (hasExpenseFilter && memberExpenses.isEmpty) {
                          continue;
                        }
                        final amount = memberExpenses.fold<double>(
                          0,
                          (total, expense) =>
                              total + _amount(expense['amount']),
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
                          log("Member----$member");
                          final name =
                              member['name']?.toString() ?? 'Unnamed member';
                          final role = member['role']?.toString() ?? 'Member';
                          final profileImage =
                              member['profileImage']?.toString() ?? '';
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
                                          color: const Color.fromARGB(255, 153, 217, 157),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: profileImage.isEmpty?Icon(Icons.person_rounded,color: Colors.black,)
                                            // ? Image.asset(
                                            //     "assets/image.png",
                                            //     fit: BoxFit.cover,
                                            //   )
                                            : Image.network(
                                                profileImage,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    // Image.asset(
                                                    //   "assets/image.png",
                                                    //   fit: BoxFit.cover,
                                                    // ),
                                                    Icon(Icons.person_2_outlined)
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
                                          color: (member['status'] == "settled")
                                              ? Colors.green
                                              : Colors.red,
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
      ),
    );
  }
}
