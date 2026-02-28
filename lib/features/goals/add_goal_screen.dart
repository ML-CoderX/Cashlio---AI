import 'package:flutter/material.dart';
import '../../core/models/goal_model.dart';
import '../../core/services/goal_repository.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  final GoalRepository _repository = GoalRepository();

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_amountController.text.isEmpty || _selectedDate == null) return;

    final goal = FinancialGoal(
      targetAmount: double.parse(_amountController.text),
      targetDate: _selectedDate!,
    );

    await _repository.clearGoal();
    await _repository.insertGoal(goal);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Target Amount"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null
                  ? "Select Target Date"
                  : _selectedDate.toString().split(" ")[0]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text("Save Goal"),
            ),
          ],
        ),
      ),
    );
  }
}