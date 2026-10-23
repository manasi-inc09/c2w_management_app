import 'package:c2w_management_app/features/expense/teamlead/domain/usescases/teamlead_expense_usecase.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool canManageExpenseCategories() {
  final email =
      FirebaseAuth.instance.currentUser?.email ?? AuthRepository.authEmail;
  return email?.startsWith('superadmin_') == true ||
      email?.startsWith('instructor_') == true;
}

abstract class ExpenseCategoryEvent {}

class LoadExpenseCategories extends ExpenseCategoryEvent {}

class SaveExpenseCategory extends ExpenseCategoryEvent {
  final String? id;
  final String name;
  final List<String> subCategories;

  SaveExpenseCategory({
    this.id,
    required this.name,
    required this.subCategories,
  });
}

abstract class ExpenseCategoryState {}

class ExpenseCategoryInitial extends ExpenseCategoryState {}

class ExpenseCategoryLoading extends ExpenseCategoryState {}

class ExpenseCategoryLoaded extends ExpenseCategoryState {
  final List<Map<String, dynamic>> categories;

  ExpenseCategoryLoaded(this.categories);
}

class ExpenseCategorySaving extends ExpenseCategoryState {}

class ExpenseCategorySaved extends ExpenseCategoryState {}

class ExpenseCategoryFailure extends ExpenseCategoryState {
  final String message;

  ExpenseCategoryFailure(this.message);
}

class ExpenseCategoryBloc
    extends Bloc<ExpenseCategoryEvent, ExpenseCategoryState> {
  final CreateExpenseUseCase _expenseUseCase;

  ExpenseCategoryBloc({required CreateExpenseUseCase expenseUseCase})
    : _expenseUseCase = expenseUseCase,
      super(ExpenseCategoryInitial()) {
    on<LoadExpenseCategories>(_load);
    on<SaveExpenseCategory>(_save);
  }

  Future<void> _load(
    LoadExpenseCategories event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategoryLoading());
    try {
      final categories = await _expenseUseCase.getExpenseCategories();
      emit(ExpenseCategoryLoaded(categories));
    } catch (error) {
      emit(ExpenseCategoryFailure(_errorMessage(error)));
    }
  }

  Future<void> _save(
    SaveExpenseCategory event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(ExpenseCategorySaving());
    try {
      if (event.id == null) {
        await _expenseUseCase.addExpenseCategory(
          name: event.name,
          subCategories: event.subCategories,
        );
      } else {
        await _expenseUseCase.updateExpenseCategory(
          id: event.id!,
          name: event.name,
          subCategories: event.subCategories,
        );
      }
      emit(ExpenseCategorySaved());
    } catch (error) {
      emit(ExpenseCategoryFailure(_errorMessage(error)));
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}
