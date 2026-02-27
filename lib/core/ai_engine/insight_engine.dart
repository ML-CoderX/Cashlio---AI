import '../models/expense_model.dart';
import 'financial_analyzer.dart';

class InsightEngine {
  final List<Expense> expenses;
  final FinancialAnalyzer analyzer;

  InsightEngine(this.expenses)
      : analyzer = FinancialAnalyzer(expenses);

  List<String> generateInsights() {
    List<String> insights = [];

    if (expenses.isEmpty) {
      insights.add("Start adding expenses to unlock financial insights.");
      return insights;
    }

    // 1️⃣ Savings Rate Insight
    if (analyzer.savingsRate < 10) {
      insights.add(
          "Your savings rate is below 10%. Consider reducing non-essential spending.");
    } else if (analyzer.savingsRate >= 20) {
      insights.add(
          "Great job! Your savings rate is healthy at ${analyzer.savingsRate.toStringAsFixed(1)}%.");
    }

    // 2️⃣ Top Category Insight
    final categoryTotals = <String, double>{};
    for (var e in expenses.where((e) => e.type == "expense")) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }

    if (categoryTotals.isNotEmpty) {
      final topCategory = categoryTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b);

      final percentage =
          analyzer.totalExpenses == 0
              ? 0
              : (topCategory.value / analyzer.totalExpenses) * 100;

      insights.add(
          "${topCategory.key} accounts for ${percentage.toStringAsFixed(0)}% of your expenses.");
    }

    // 3️⃣ Prediction Risk Insight
    if (analyzer.predictedSavings < 0) {
      insights.add(
          "Based on current trends, you may overspend next month.");
    }

    // 4️⃣ Positive Reinforcement
    if (analyzer.healthScore >= 80) {
      insights.add(
          "Your financial health is excellent. Keep maintaining this discipline.");
    }

    return insights;
  }
}