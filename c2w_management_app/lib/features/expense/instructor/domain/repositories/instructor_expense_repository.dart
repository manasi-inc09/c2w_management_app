import 'package:c2w_management_app/features/expense/teamlead/domain/entities/teamlead_expense.dart';

abstract class InstructorExpenseRepository {
  Future<String> createExpense(Expense expense);
}
