import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashlio"),
      ),
      body: const Center(
        child: Text(
          "Welcome to Cashlio 💰",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}