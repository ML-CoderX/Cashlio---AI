import '../models/expense_model.dart';

class FinancialAnalyzer {
  final List<Expense> expenses;

  FinancialAnalyzer(this.expenses);

  double get totalIncome =>
      expenses.where((e) => e.type == "income")
          .fold(0, (sum, e) => sum + e.amount);

  double get totalExpenses =>
      expenses.where((e) => e.type == "expense")
          .fold(0, (sum, e) => sum + e.amount);

  double get netSavings => totalIncome - totalExpenses;

  double get savingsRate =>
      totalIncome == 0 ? 0 : (netSavings / totalIncome) * 100;

  int get healthScore {
    if (savingsRate >= 40) return 90;
    if (savingsRate >= 20) return 75;
    if (savingsRate >= 10) return 60;
    if (savingsRate > 0) return 40;
    return 20;
  }

  Map<int, double> _monthlyData(String type) {
    final Map<int, double> data = {};
    for (var e in expenses.where((e) => e.type == type)) {
      final month = e.date.month;
      data[month] = (data[month] ?? 0) + e.amount;
    }
    return data;
  }

  double _movingAverage(Map<int, double> monthlyData) {
    if (monthlyData.isEmpty) return 0;

    final sortedMonths = monthlyData.keys.toList()..sort();
    final last3 = sortedMonths.reversed.take(3);

    double total = 0;
    int count = 0;

    for (var m in last3) {
      total += monthlyData[m]!;
      count++;
    }

    return count == 0 ? 0 : total / count;
  }

  double get predictedExpense =>
      _movingAverage(_monthlyData("expense"));

  double get predictedIncome =>
      _movingAverage(_monthlyData("income"));

  double get predictedSavings =>
      predictedIncome - predictedExpense;

  bool get hasEnoughPredictionData {
    return _monthlyData("expense").keys.length >= 3 &&
        _monthlyData("income").keys.length >= 3;
  }
}