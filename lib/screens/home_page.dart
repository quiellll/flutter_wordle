import 'package:flutter/material.dart';
import 'package:flutter_wordle/models/models.dart';
import 'package:flutter_wordle/screens/game_page.dart';
import 'package:flutter_wordle/utils/transitions.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';
import 'package:flutter_wordle/widgets/theme/theme_toggle.dart';
import 'package:flutter_wordle/widgets/user/user_profile.dart';
import 'package:flutter_wordle/widgets/user/user_profile_button.dart';

class HomePage extends StatefulWidget {
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeTitle;
  late Animation<double> _fadeWelcome;
  late Animation<double> _fadeStats;
  late Animation<double> _fadeButtons;
  late Animation<Offset> _slideWelcome;
  late Animation<Offset> _slideUsername;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeTitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _fadeWelcome = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _fadeStats = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _fadeButtons = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _slideWelcome = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    _slideUsername = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame(BuildContext context, Language language) {
    Navigator.of(context).push(
      SlideRoute(
        page: GamePage(
          language: language,
          onGameComplete: (won, attempts) {
            final newGamesPlayed = widget.userStats.gamesPlayed + 1;
            final newGamesWon = widget.userStats.gamesWon + (won ? 1 : 0);
            final totalAttempts = (widget.userStats.avgAttempts * widget.userStats.gamesPlayed) + attempts;
            final newAvgAttempts = totalAttempts / newGamesPlayed;

            final newStats = UserStats(
              username: widget.userStats.username,
              gamesPlayed: newGamesPlayed,
              gamesWon: newGamesWon,
              avgAttempts: newAvgAttempts,
            );

            widget.onStatsUpdated(newStats);
          },
        ),
        direction: SlideDirection.up,  // You can change this to .left, .up, or .down
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
              FadeTransition(
                opacity: _fadeTitle,
                child: Container(
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
                        userStats: widget.userStats,
                        onStatsUpdated: widget.onStatsUpdated,
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideTransition(
                          position: _slideWelcome,
                          child: FadeTransition(
                            opacity: _fadeWelcome,
                            child: Text(
                              'Hola,',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _slideUsername,
                          child: FadeTransition(
                            opacity: _fadeWelcome,
                            child: Text(
                              widget.userStats.username,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fadeWelcome,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Tienes 6 intentos para adivinar la palabra',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        FadeTransition(
                          opacity: _fadeStats,
                          child: Container(
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
                                _buildStatItem('Jugadas', widget.userStats.gamesPlayed.toString()),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                _buildStatItem('Ganadas', widget.userStats.gamesWon.toString()),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                _buildStatItem('Tu media', widget.userStats.avgAttempts.toStringAsFixed(1)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),
                        FadeTransition(
                          opacity: _fadeButtons,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildLanguageButton(
                                  context,
                                  'Inglés',
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
}