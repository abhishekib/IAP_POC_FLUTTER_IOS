// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/iap_test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAP Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const IAPTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}