import 'package:flutter/material.dart';
import '../../core/models/expense_model.dart';
import '../../core/models/goal_model.dart';
import '../../core/services/expense_repository.dart';
import '../../core/services/goal_repository.dart';
import '../../core/services/export_service.dart';
import '../../core/ai_engine/financial_analyzer.dart';
import '../../core/ai_engine/insight_engine.dart';
import '../../core/ai_engine/goal_analyzer.dart';
import '../expenses/add_expense_screen.dart';
import '../goals/add_goal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  final GoalRepository _goalRepository = GoalRepository();
  final ExportService _exportService = ExportService();

  List<Expense> _expenses = [];
  FinancialGoal? _goal;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadGoal();
  }

  Future<void> _loadExpenses() async {
    final data = await _repository.getAllExpenses();
    setState(() {
      _expenses = data;
    });
  }

  Future<void> _loadGoal() async {
    final goal = await _goalRepository.getGoal();
    setState(() {
      _goal = goal;
    });
  }

  Color _healthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _goalStatusColor(String status) {
    if (status == "On Track") return Colors.green;
    if (status == "Tight") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final analyzer = FinancialAnalyzer(_expenses);
    final insights = InsightEngine(_expenses).generateInsights();
    final healthColor = _healthColor(analyzer.healthScore);

    GoalAnalyzer? goalAnalyzer;
    if (_goal != null) {
      goalAnalyzer = GoalAnalyzer(
        goal: _goal!,
        analyzer: analyzer,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashlio"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "csv") {
                _exportService.exportToCSV(_expenses);
              } else if (value == "pdf") {
                _exportService.exportToPDF(_expenses, _goal);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "csv",
                child: Text("Export CSV"),
              ),
              PopupMenuItem(
                value: "pdf",
                child: Text("Export PDF Report"),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ===== SUMMARY =====
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Income: ₹${analyzer.totalIncome.toStringAsFixed(2)}"),
                  Text("Expenses: ₹${analyzer.totalExpenses.toStringAsFixed(2)}"),
                  Text("Net Savings: ₹${analyzer.netSavings.toStringAsFixed(2)}"),
                  Text("Savings Rate: ${analyzer.savingsRate.toStringAsFixed(1)}%"),
                ],
              ),
            ),

            // ===== HEALTH SCORE =====
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: healthColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: healthColor, width: 2),
              ),
              child: Column(
                children: [
                  const Text("Financial Health Score"),
                  const SizedBox(height: 6),
                  Text(
                    "${analyzer.healthScore} / 100",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: healthColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== PREDICTION =====
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Month Forecast",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (!analyzer.hasEnoughPredictionData)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "⚠ Add at least 3 months of data for reliable forecasting.",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),

                  const SizedBox(height: 10),
                  Text("Predicted Income: ₹${analyzer.predictedIncome.toStringAsFixed(2)}"),
                  Text("Predicted Expense: ₹${analyzer.predictedExpense.toStringAsFixed(2)}"),
                  Text(
                    "Predicted Savings: ₹${analyzer.predictedSavings.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: analyzer.predictedSavings >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== SMART INSIGHTS =====
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Smart Insights",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...insights.map(
                    (insight) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("• $insight"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== GOAL SECTION =====
            if (_goal == null)
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddGoalScreen()),
                  );
                  if (result == true) _loadGoal();
                },
                child: const Text("Create Savings Goal"),
              )
            else if (goalAnalyzer != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Savings Goal",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Target: ₹${_goal!.targetAmount.toStringAsFixed(0)}"),
                    Text("Months Remaining: ${_goal!.monthsRemaining}"),
                    Text(
                        "Required Monthly: ₹${goalAnalyzer.requiredMonthlySaving.toStringAsFixed(2)}"),
                    Text(
                        "Available Monthly: ₹${goalAnalyzer.availableMonthlySaving.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    Text(
                      "Status: ${goalAnalyzer.status}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _goalStatusColor(goalAnalyzer.status),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ===== EXPENSE LIST =====
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle: Text("${expense.category} • ${expense.type}"),
                    trailing: Text(
                      "₹${expense.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: expense.type == "income"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddExpenseScreen()),
          );
          if (result == true) _loadExpenses();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}