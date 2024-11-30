import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';
import 'package:flutter_wordle/widgets/theme/theme_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/screens/game_page.dart';
import 'package:flutter_wordle/widgets/user/user_profile.dart';
import 'package:flutter_wordle/widgets/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(asyncPrefs),
      child: WordleApp(prefs: asyncPrefs),  // Add the prefs parameter here
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

class HomePage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final UserStats userStats;
  final Function(UserStats) onStatsUpdated;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.userStats,
    required this.onStatsUpdated,
  });

  void _startGame(BuildContext context, Language language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamePage(language: language),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Text(
                      'WORDLE',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const ThemeToggle(),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) => UserProfile(
                            initialStats: userStats,
                            onStatsUpdated: onStatsUpdated,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Welcome message
              const SizedBox(height: 40),
              Text(
                'Welcome, ${userStats.username}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Guess the word within 6 attempts',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              // Stats overview
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[200]
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Played', userStats.gamesPlayed.toString()),
                    _buildStatItem('Won', userStats.gamesWon.toString()),
                    _buildStatItem('Avg. Attempts', userStats.avgAttempts.toStringAsFixed(1)),
                  ],
                ),
              ),

              // Language selection buttons
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(
                      context,
                      'English',
                      WordleColors().englishButton,
                      () => _startGame(context, Language.english),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildLanguageButton(
                      context,
                      'Español',
                      WordleColors().spanishButton,
                      () => _startGame(context, Language.spanish),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String language,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        language,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}