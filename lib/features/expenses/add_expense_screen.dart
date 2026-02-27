import 'package:flutter/material.dart';
import '../../core/models/expense_model.dart';
import '../../core/services/expense_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = "Food";
  String _selectedType = "expense";

  final ExpenseRepository _repository = ExpenseRepository();

  final List<String> _categories = [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Other"
  ];

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: DateTime.now(),
      isRecurring: false,
      type: _selectedType,
    );

    await _repository.insertExpense(expense);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Category",
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(
                    value: "expense",
                    child: Text("Expense"),
                  ),
                  DropdownMenuItem(
                    value: "income",
                    child: Text("Income"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Type",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}