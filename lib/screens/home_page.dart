import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/screens/game_page.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';
import 'package:flutter_wordle/widgets/theme/theme_toggle.dart';
import 'package:flutter_wordle/widgets/user/user_profile_button.dart';
import 'package:flutter_wordle/widgets/user/user_profile.dart';

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
        builder: (context) => GamePage(
          language: language,
          onGameComplete: (won, attempts) {
            final newGamesPlayed = userStats.gamesPlayed + 1;
            final newGamesWon = userStats.gamesWon + (won ? 1 : 0);
            final totalAttempts = (userStats.avgAttempts * userStats.gamesPlayed) + attempts;
            final newAvgAttempts = totalAttempts / newGamesPlayed;

            final newStats = UserStats(
              username: userStats.username,
              gamesPlayed: newGamesPlayed,
              gamesWon: newGamesWon,
              avgAttempts: newAvgAttempts,
            );

            onStatsUpdated(newStats);
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String language,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          language,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.light 
        ? Colors.grey.shade100 
        : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    const Text(
                      'WORDLE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    const ThemeToggle(),
                    UserProfileButton(
                      userStats: userStats,
                      onStatsUpdated: onStatsUpdated,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          userStats.username,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guess the word within 6 attempts',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Stats overview
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                          decoration: BoxDecoration(
                            color: brightness == Brightness.light
                                ? Colors.white
                                : const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _buildStatItem('Played', userStats.gamesPlayed.toString()),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              _buildStatItem('Won', userStats.gamesWon.toString()),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              _buildStatItem('Avg. Attempts', userStats.avgAttempts.toStringAsFixed(1)),
                            ],
                          ),
                        ),

                        // Language selection buttons
                        const SizedBox(height: 48),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLanguageButton(
                                context,
                                'English',
                                WordleColors.englishButton,
                                () => _startGame(context, Language.english),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildLanguageButton(
                                context,
                                'Español',
                                WordleColors.spanishButton,
                                () => _startGame(context, Language.spanish),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}