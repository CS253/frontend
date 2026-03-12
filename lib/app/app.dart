import 'package:flutter/material.dart';
import 'package:travelly/core/theme/app_theme.dart';
import 'package:travelly/features/navigation/presentation/screens/main_screen.dart';

/// Root application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelly',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
