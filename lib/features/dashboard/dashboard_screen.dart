import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/expense_model.dart';
import '../../core/services/expense_repository.dart';
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

  double get totalIncome =>
      _expenses.where((e) => e.type == "income").fold(0, (sum, e) => sum + e.amount);

  double get totalExpenses =>
      _expenses.where((e) => e.type == "expense").fold(0, (sum, e) => sum + e.amount);

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

  Color get healthColor {
    if (healthScore >= 80) return Colors.green;
    if (healthScore >= 60) return Colors.lightGreen;
    if (healthScore >= 40) return Colors.orange;
    return Colors.red;
  }

  Map<int, double> get monthlyExpenses {
    final Map<int, double> data = {};
    for (var e in _expenses.where((e) => e.type == "expense")) {
      final month = e.date.month;
      data[month] = (data[month] ?? 0) + e.amount;
    }
    return data;
  }

  Map<int, double> get monthlyIncome {
    final Map<int, double> data = {};
    for (var e in _expenses.where((e) => e.type == "income")) {
      final month = e.date.month;
      data[month] = (data[month] ?? 0) + e.amount;
    }
    return data;
  }

  List<FlSpot> get expenseSpots {
    return monthlyExpenses.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  List<FlSpot> get incomeSpots {
    return monthlyIncome.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cashlio")),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // Summary
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
                  Text("Income: ₹${totalIncome.toStringAsFixed(2)}"),
                  Text("Expenses: ₹${totalExpenses.toStringAsFixed(2)}"),
                  Text("Net Savings: ₹${netSavings.toStringAsFixed(2)}"),
                  Text("Savings Rate: ${savingsRate.toStringAsFixed(1)}%"),
                ],
              ),
            ),

            // Health Score
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
                  Text(
                    "Financial Health Score",
                    style: TextStyle(fontWeight: FontWeight.bold, color: healthColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$healthScore / 100",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: healthColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Monthly Trend Graph
            if (expenseSpots.isNotEmpty || incomeSpots.isNotEmpty)
              Column(
                children: [
                  const Text(
                    "Monthly Trend",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: expenseSpots,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                          ),
                          LineChartBarData(
                            spots: incomeSpots,
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Expense List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (result == true) _loadExpenses();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}