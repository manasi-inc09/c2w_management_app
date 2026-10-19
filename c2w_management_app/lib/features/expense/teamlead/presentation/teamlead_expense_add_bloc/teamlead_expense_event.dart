import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

abstract class CreateExpenseEvent {}

class SubmitExpenseEvent extends CreateExpenseEvent {
  final Expense expense;

  SubmitExpenseEvent(this.expense);
}
