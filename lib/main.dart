import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const CashlioApp());
}

class CashlioApp extends StatelessWidget {
  const CashlioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashlio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}