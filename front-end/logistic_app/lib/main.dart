import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(LogisticDashboardApp());
}

class LogisticDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel de Gestión Logística',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: DashboardScreen(),
    );
  }
}
