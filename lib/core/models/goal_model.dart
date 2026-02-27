class FinancialGoal {
  final double targetAmount;
  final DateTime targetDate;

  FinancialGoal({
    required this.targetAmount,
    required this.targetDate,
  });

  int get monthsRemaining {
    final now = DateTime.now();
    int months = (targetDate.year - now.year) * 12 +
        (targetDate.month - now.month);
    return months <= 0 ? 1 : months;
  }
}