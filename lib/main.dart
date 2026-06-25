import 'package:flutter/material.dart';
import 'screens/dashboard_calc.dart';

void main() => runApp(const MathProApp());

class MathProApp extends StatelessWidget {
  const MathProApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MathPro',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004D40), brightness: Brightness.dark),
      useMaterial3: true,
    ),
    home: const MathProScreen(),
  );
}
