import 'package:flutter/material.dart';
import '../../core/models/expense_model.dart';
import '../../core/services/expense_repository.dart';
import '../../core/ai_engine/financial_analyzer.dart';
import '../expenses/add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _repository.getAllExpenses();
    setState(() {
      _expenses = data;
    });
  }

  Color _healthColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final analyzer = FinancialAnalyzer(_expenses);
    final healthColor = _healthColor(analyzer.healthScore);

    return Scaffold(
      appBar: AppBar(title: const Text("Cashlio")),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ===== SUMMARY CARD =====
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
                  Text(
                      "Savings Rate: ${analyzer.savingsRate.toStringAsFixed(1)}%"),
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

            // ===== PREDICTION PANEL =====
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
                    "Next Month Forecast (Moving Average)",
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
                        "⚠ Prediction may be inaccurate. Add at least 3 months of data for reliable forecasting.",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),

                  const SizedBox(height: 10),

                  Text(
                      "Predicted Income: ₹${analyzer.predictedIncome.toStringAsFixed(2)}"),
                  Text(
                      "Predicted Expense: ₹${analyzer.predictedExpense.toStringAsFixed(2)}"),
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

            // ===== EXPENSE LIST =====
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle:
                        Text("${expense.category} • ${expense.type}"),
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
              builder: (_) => const AddExpenseScreen(),
            ),
          );

          if (result == true) {
            _loadExpenses();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}