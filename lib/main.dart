import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wordle/user_profile.dart';

void main() async {
  // Para que SharedPreferences funcione correctamente, necesitamos
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar las SharedPreferences
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  runApp(WordleApp(prefs: asyncPrefs));
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
  bool isDarkMode = false;
  late UserStats userStats;

  @override
  void initState() {
    super.initState();
    userStats = UserStats(username: 'Player');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Get theme setting with null safety
      final bool? darkMode = await widget.prefs.getBool('isDarkMode');
      isDarkMode = darkMode ?? false;  // Use false as default if null

      // Get user stats with null safety
      final String? statsString = await widget.prefs.getString('userStats');
      
      if (statsString != null) {
        try {
          // Parse string into a map
          Map<String, dynamic> statsMap = Map<String, dynamic>.from(
            // Use jsondecode to parse the stored JSON string
            jsonDecode(statsString)
          );
          userStats = UserStats.fromJson(statsMap);
        } catch (e) {
          // If there's an error parsing the stats, use default
          userStats = UserStats(username: 'Player');
        }
      } else {
        // If no stats exist yet, use default
        userStats = UserStats(username: 'Player');
      }
      
      // Update the UI
      setState(() {});
    } catch (e) {
      // Set defaults
      isDarkMode = false;
      userStats = UserStats(username: 'Player');
      setState(() {});
    }
  }

  Future<void> _saveSettings() async {
    await widget.prefs.setBool('isDarkMode', isDarkMode);
    final statsJson = jsonEncode(userStats.toJson());
    await widget.prefs.setString('userStats', statsJson);
  }

  void _updateUserStats(UserStats newStats) {
    setState(() {
      userStats = newStats;
      _saveSettings();
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: HomePage(
        isDarkMode: isDarkMode,
        onThemeToggle: _toggleTheme,
        userStats: userStats,
        onStatsUpdated: _updateUserStats,
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
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                      onPressed: onThemeToggle,
                    ),
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
                      Colors.blue,
                      () {
                        // Start game with English words
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildLanguageButton(
                      context,
                      'Español',
                      Colors.orange,
                      () {
                        // Start game with Spanish words
                      },
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