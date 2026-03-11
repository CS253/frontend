import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'main_screen.dart';
import 'app_providers.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'Travelly',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
