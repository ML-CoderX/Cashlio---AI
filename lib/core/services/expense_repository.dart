import '../database/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertExpense(Expense expense) async {
    final db = await dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await dbHelper.database;
    final result = await db.query('expenses', orderBy: 'date DESC');

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}