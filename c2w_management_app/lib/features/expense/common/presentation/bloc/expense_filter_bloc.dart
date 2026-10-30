import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/expense/common/presentation/bloc/expense_category_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadExpenseFilterOptions {}

class ApplyExpenseFilters {
  final ExpenseFilterSelection selection;

  ApplyExpenseFilters(this.selection);
}

class ResetExpenseFilters {}

class ExpenseFilterSelection {
  final String transactionType;
  final String? company;
  final String? category;
  final String? subCategory;
  final String? memberEmail;
  final String? memberName;
  final DateTime? date;

  const ExpenseFilterSelection({
    this.transactionType = 'All Transactions',
    this.company,
    this.category,
    this.subCategory,
    this.memberEmail,
    this.memberName,
    this.date,
  });

  ExpenseFilterSelection copyWith({
    String? transactionType,
    String? company,
    bool clearCompany = false,
    String? category,
    bool clearCategory = false,
    String? subCategory,
    bool clearSubCategory = false,
    String? memberEmail,
    String? memberName,
    bool clearMember = false,
    DateTime? date,
    bool clearDate = false,
  }) {
    return ExpenseFilterSelection(
      transactionType: transactionType ?? this.transactionType,
      company: clearCompany ? null : company ?? this.company,
      category: clearCategory ? null : category ?? this.category,
      subCategory: clearSubCategory ? null : subCategory ?? this.subCategory,
      memberEmail: clearMember ? null : memberEmail ?? this.memberEmail,
      memberName: clearMember ? null : memberName ?? this.memberName,
      date: clearDate ? null : date ?? this.date,
    );
  }

  int get activeFilterCount {
    var count = transactionType == 'All Transactions' ? 0 : 1;
    if (company != null) count++;
    if (category != null) count++;
    if (memberEmail != null) count++;
    if (date != null) count++;
    return count;
  }

  List<String> get labels => [
    if (transactionType != 'All Transactions') transactionType,
    if (company != null) 'Company: $company',
    if (category != null)
      subCategory == null ? category! : '$category • $subCategory',
    if (memberEmail != null) memberName ?? memberEmail!,
    if (date != null)
      '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}',
  ];
}

class ExpenseFilterInitial {
  final ExpenseFilterSelection selection;

  ExpenseFilterInitial({this.selection = const ExpenseFilterSelection()});
}

class ExpenseFilterLoading extends ExpenseFilterInitial {
  ExpenseFilterLoading({super.selection});
}

class ExpenseFilterLoaded extends ExpenseFilterInitial {
  final List<String> companies;
  final Map<String, String> categoryCompanies;
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final List<Map<String, dynamic>> members;

  ExpenseFilterLoaded({
    required this.companies,
    required this.categoryCompanies,
    required this.categories,
    required this.subCategories,
    required this.members,
    required super.selection,
  });
}

class ExpenseFilterFailure extends ExpenseFilterInitial {
  final String message;

  ExpenseFilterFailure({required this.message, required super.selection});
}

class ExpenseFilterBloc extends Bloc<Object, ExpenseFilterInitial> {
  final CreateExpenseUseCase _expenseUseCase;

  ExpenseFilterBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(ExpenseFilterInitial()) {
    on<LoadExpenseFilterOptions>(_loadOptions);
    on<ApplyExpenseFilters>((event, emit) {
      emit(_withSelection(state, event.selection));
    });
    on<ResetExpenseFilters>((event, emit) {
      emit(_withSelection(state, const ExpenseFilterSelection()));
    });
  }

  Future<void> _loadOptions(
    LoadExpenseFilterOptions event,
    Emitter<ExpenseFilterInitial> emit,
  ) async {
    emit(ExpenseFilterLoading(selection: state.selection));
    try {
      final results = await Future.wait([
        _expenseUseCase.getExpenseCategories(),
        _expenseUseCase.getMembers(),
      ]);
      final categoryDocuments = results[0];
      final members = results[1];
      final categories = <String>[];
      final companies = <String>{...expenseCompanies};
      final categoryCompanies = <String, String>{};
      final subCategories = <String, List<String>>{};

      for (final document in categoryDocuments) {
        final name = document['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        categories.add(name);
        final company = document['company']?.toString().trim() ?? '';
        if (company.isNotEmpty) {
          companies.add(company);
          categoryCompanies[name] = company;
        }
        final values = document['subCategories'];
        subCategories[name] = values is List
            ? values.map((value) => value.toString()).toList()
            : <String>[];
      }

      emit(
        ExpenseFilterLoaded(
          companies: companies.toList(),
          categoryCompanies: categoryCompanies,
          categories: categories,
          subCategories: subCategories,
          members: members,
          selection: state.selection,
        ),
      );
    } catch (error) {
      emit(
        ExpenseFilterFailure(
          message: _errorMessage(error),
          selection: state.selection,
        ),
      );
    }
  }

  ExpenseFilterInitial _withSelection(
    ExpenseFilterInitial current,
    ExpenseFilterSelection selection,
  ) {
    if (current is ExpenseFilterLoaded) {
      return ExpenseFilterLoaded(
        companies: current.companies,
        categoryCompanies: current.categoryCompanies,
        categories: current.categories,
        subCategories: current.subCategories,
        members: current.members,
        selection: selection,
      );
    }
    if (current is ExpenseFilterFailure) {
      return ExpenseFilterFailure(
        message: current.message,
        selection: selection,
      );
    }
    if (current is ExpenseFilterLoading) {
      return ExpenseFilterLoading(selection: selection);
    }
    return ExpenseFilterInitial(selection: selection);
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}

List<Map<String, dynamic>> filterExpenses(
  List<Map<String, dynamic>> expenses,
  ExpenseFilterSelection selection, {
  required String? currentEmail,
  Map<String, String> categoryCompanies = const {},
}) {
  final now = DateTime.now();
  final recentStart = now.subtract(const Duration(days: 7));

  return expenses.where((expense) {
    final email = expense['email']?.toString().toLowerCase();
    final isGroupTotal =
        expense['eventExpenseGroup'] == true &&
        expense['eventExpenseGroupContribution'] != true;
    if (selection.transactionType == 'My Transactions' && !isGroupTotal) {
      final currentRawEmail = currentEmail?.toLowerCase() ?? '';
      final normalizedCurrentEmail = _normalizeEmail(
        currentEmail ?? '',
      ).toLowerCase();
      final normalizedExpenseEmail = email == null
          ? null
          : _normalizeEmail(email).toLowerCase();

      final matchesCurrentUser =
          currentEmail != null &&
          (email == currentRawEmail ||
              email == normalizedCurrentEmail ||
              normalizedExpenseEmail == normalizedCurrentEmail ||
              normalizedExpenseEmail == currentRawEmail);

      if (!matchesCurrentUser) {
        return false;
      }
    }
    final date = _expenseDate(expense);
    if (selection.transactionType == 'Recent Transactions' &&
        (date == null || date.isBefore(recentStart) || date.isAfter(now))) {
      return false;
    }
    if (selection.company != null) {
      final expenseCompany =
          expense['company']?.toString() ??
          categoryCompanies[expense['category']?.toString()];
      if (expenseCompany != selection.company) return false;
    }
    if (selection.category != null &&
        expense['category']?.toString() != selection.category) {
      return false;
    }
    if (selection.subCategory != null &&
        expense['subCategory']?.toString() != selection.subCategory) {
      return false;
    }
    if (selection.memberEmail != null &&
        email != selection.memberEmail!.toLowerCase()) {
      return false;
    }
    if (selection.date != null &&
        (date == null ||
            date.year != selection.date!.year ||
            date.month != selection.date!.month ||
            date.day != selection.date!.day)) {
      return false;
    }
    return true;
  }).toList();
}

DateTime? _expenseDate(Map<String, dynamic> expense) {
  final value = expense['expenseDate'];
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  final submittedAt = expense['submittedAt'];
  if (submittedAt is Timestamp) return submittedAt.toDate();
  if (submittedAt is DateTime) return submittedAt;
  return null;
}

String _normalizeEmail(String email) {
  for (final role in ['teamlead', 'mentor', 'instructor', 'superadmin']) {
    final prefix = '${role}_';
    if (email.startsWith(prefix)) return email.substring(prefix.length);
  }
  return email;
}
