import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: Icon(
            provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          onPressed: () => provider.toggleTheme(),
        );
      },
    );
  }
}