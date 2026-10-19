import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

abstract class TeamleadExpenses{

}

class TeamleadExpenseEvent extends TeamleadExpenses{
  final Expense expense;
  TeamleadExpenseEvent(this.expense);
}

