abstract class CreateExpenseState {}

class CreateExpenseInitial extends CreateExpenseState {}

class CreateExpenseLoading extends CreateExpenseState {}

class CreateExpenseSuccess extends CreateExpenseState {}

class CreateExpenseFailure extends CreateExpenseState {
  final String message;

  CreateExpenseFailure(this.message);
}
