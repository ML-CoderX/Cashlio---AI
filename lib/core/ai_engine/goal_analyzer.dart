import '../models/goal_model.dart';
import 'financial_analyzer.dart';

class GoalAnalyzer {
  final FinancialGoal goal;
  final FinancialAnalyzer analyzer;

  GoalAnalyzer({
    required this.goal,
    required this.analyzer,
  });

  double get requiredMonthlySaving =>
      goal.targetAmount / goal.monthsRemaining;

  double get availableMonthlySaving =>
      analyzer.predictedSavings;

  double get stressIndex =>
      availableMonthlySaving == 0
          ? double.infinity
          : requiredMonthlySaving / availableMonthlySaving;

  String get status {
    if (availableMonthlySaving <= 0) {
      return "Unrealistic";
    }
    if (stressIndex <= 0.7) return "On Track";
    if (stressIndex <= 1.0) return "Tight";
    if (stressIndex <= 1.5) return "Risky";
    return "Unrealistic";
  }
}