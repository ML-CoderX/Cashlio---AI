import 'package:flutter/material.dart';
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
      _expenses
          .where((e) => e.type == "income")
          .fold(0, (sum, e) => sum + e.amount);

  double get totalExpenses =>
      _expenses
          .where((e) => e.type == "expense")
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

  Color get healthColor {
    if (healthScore >= 80) return Colors.green;
    if (healthScore >= 60) return Colors.lightGreen;
    if (healthScore >= 40) return Colors.orange;
    return Colors.red;
  }

  String get healthLabel {
    if (healthScore >= 80) return "Excellent";
    if (healthScore >= 60) return "Good";
    if (healthScore >= 40) return "Needs Improvement";
    return "Critical";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashlio"),
      ),
      body: Column(
        children: [
          // Financial Summary Card
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

          // Health Score Card
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$healthScore / 100",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  healthLabel,
                  style: TextStyle(color: healthColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Expense List
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text("No expenses yet"))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(expense.title),
                          subtitle: Text(
                              "${expense.category} • ${expense.type}"),
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
          ),
        ],
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