import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: FintrackApp()));
}

class FintrackApp extends StatelessWidget {
  const FintrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintrack',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const Scaffold(body: Center(child: Text('Fintrack'))),
    );
  }
}
