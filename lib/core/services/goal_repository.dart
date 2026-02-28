import '../database/database_helper.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> insertGoal(FinancialGoal goal) async {
    final db = await dbHelper.database;
    await db.insert('goals', {
      'targetAmount': goal.targetAmount,
      'targetDate': goal.targetDate.toIso8601String(),
    });
  }

  Future<FinancialGoal?> getGoal() async {
    final db = await dbHelper.database;
    final result = await db.query('goals', limit: 1);

    if (result.isEmpty) return null;

    return FinancialGoal(
      targetAmount: result.first['targetAmount'] as double,
      targetDate: DateTime.parse(result.first['targetDate'] as String),
    );
  }

  Future<void> clearGoal() async {
    final db = await dbHelper.database;
    await db.delete('goals');
  }
}