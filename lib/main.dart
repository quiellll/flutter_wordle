import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordle/widgets/user/user_profile.dart';
import 'package:flutter_wordle/widgets/theme/theme_provider.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';
import 'package:flutter_wordle/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(asyncPrefs),
      child: WordleApp(prefs: asyncPrefs),
    ),
  );
}

class WordleApp extends StatefulWidget {
  final SharedPreferencesAsync prefs;

  const WordleApp({
    super.key,
    required this.prefs,
  });

  @override
  State<WordleApp> createState() => _WordleAppState();
}

class _WordleAppState extends State<WordleApp> {
  late ThemeProvider themeProvider;
  late UserStats userStats;

  @override
  void initState() {
    super.initState();
    themeProvider = ThemeProvider(widget.prefs);
    userStats = UserStats(username: 'Player');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final String? statsString = await widget.prefs.getString('userStats');
      
      if (statsString != null) {
        try {
          Map<String, dynamic> statsMap = Map<String, dynamic>.from(
            jsonDecode(statsString)
          );
          userStats = UserStats.fromJson(statsMap);
        } catch (e) {
          userStats = UserStats(username: 'Player');
        }
      }
      
      setState(() {});
    } catch (e) {
      userStats = UserStats(username: 'Player');
      setState(() {});
    }
  }

  Future<void> _saveSettings() async {
    final statsJson = jsonEncode(userStats.toJson());
    await widget.prefs.setString('userStats', statsJson);
  }

  void _updateUserStats(UserStats newStats) {
    setState(() {
      userStats = newStats;
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Wordle',
            theme: WordleColors.getLightTheme(),
            darkTheme: WordleColors.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: HomePage(
              isDarkMode: themeProvider.isDarkMode,
              onThemeToggle: themeProvider.toggleTheme,
              userStats: userStats,
              onStatsUpdated: _updateUserStats,
            ),
          );
        },
      ),
    );
  }
}