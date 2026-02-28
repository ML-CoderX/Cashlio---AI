import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/expense_model.dart';
import '../ai_engine/financial_analyzer.dart';
import '../models/goal_model.dart';
import '../ai_engine/goal_analyzer.dart';

class ExportService {

  // ================= CSV EXPORT =================

  Future<void> exportToCSV(List<Expense> expenses) async {
    if (expenses.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln("Title,Amount,Category,Type,Date");

    for (var e in expenses) {
      buffer.writeln(
          "${e.title},${e.amount},${e.category},${e.type},${e.date.toIso8601String()}");
    }

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/cashlio_export.csv");

    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)],
        text: "Cashlio Expense Export");
  }

  // ================= PDF EXPORT =================

  Future<void> exportToPDF(
      List<Expense> expenses,
      FinancialGoal? goal,
      ) async {

    final pdf = pw.Document();
    final analyzer = FinancialAnalyzer(expenses);

    GoalAnalyzer? goalAnalyzer;
    if (goal != null) {
      goalAnalyzer = GoalAnalyzer(goal: goal, analyzer: analyzer);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Text("Cashlio Financial Report",
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold)),

          pw.SizedBox(height: 20),

          pw.Text("Income: ₹${analyzer.totalIncome.toStringAsFixed(2)}"),
          pw.Text("Expenses: ₹${analyzer.totalExpenses.toStringAsFixed(2)}"),
          pw.Text("Net Savings: ₹${analyzer.netSavings.toStringAsFixed(2)}"),
          pw.Text("Savings Rate: ${analyzer.savingsRate.toStringAsFixed(1)}%"),
          pw.Text("Health Score: ${analyzer.healthScore}/100"),

          pw.SizedBox(height: 20),

          if (goalAnalyzer != null) ...[
            pw.Text("Goal Summary",
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Target: ₹${goal!.targetAmount.toStringAsFixed(0)}"),
            pw.Text("Months Remaining: ${goal.monthsRemaining}"),
            pw.Text(
                "Required Monthly: ₹${goalAnalyzer.requiredMonthlySaving.toStringAsFixed(2)}"),
            pw.Text(
                "Available Monthly: ₹${goalAnalyzer.availableMonthlySaving.toStringAsFixed(2)}"),
            pw.Text("Status: ${goalAnalyzer.status}"),
          ],

          pw.SizedBox(height: 20),

          pw.Text("Transactions",
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold)),

          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ["Title", "Amount", "Category", "Type"],
            data: expenses.map((e) => [
              e.title,
              e.amount.toStringAsFixed(2),
              e.category,
              e.type
            ]).toList(),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/cashlio_report.pdf");

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)],
        text: "Cashlio Financial Report");
  }
}