import 'package:flutter/material.dart';
import 'package:flutter_wordle/widgets/theme/theme_colors.dart';

// User stats model
class UserStats {
  final String username;
  final int gamesPlayed;
  final int gamesWon;
  final double avgAttempts;

  UserStats({
    required this.username,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.avgAttempts = 0,
  });

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'username': username,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'avgAttempts': avgAttempts,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    username: json['username'] as String? ?? 'Player',
    gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    gamesWon: json['gamesWon'] as int? ?? 0,
    avgAttempts: (json['avgAttempts'] as num?)?.toDouble() ?? 0.0,
  );
}

// User profile dialog
class UserProfile extends StatefulWidget {
  final UserStats initialStats;
  final Function(UserStats) onStatsUpdated;

  const UserProfile({
    super.key,
    required this.initialStats,
    required this.onStatsUpdated,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late TextEditingController _usernameController;
  late UserStats currentStats;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    currentStats = widget.initialStats;
    _usernameController = TextEditingController(text: currentStats.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _resetAllData() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will reset your username and all game statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentStats = UserStats(username: 'Player');
                _usernameController.text = 'Player';
              });
              widget.onStatsUpdated(currentStats);
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: WordleColors.important),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    setState(() {
      currentStats = UserStats(
        username: _usernameController.text.trim(),
        gamesPlayed: currentStats.gamesPlayed,
        gamesWon: currentStats.gamesWon,
        avgAttempts: currentStats.avgAttempts,
      );
      _isEditing = false;
    });
    widget.onStatsUpdated(currentStats);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? WordleColors.darkTheme
        : WordleColors.lightTheme;

    return Dialog(
      backgroundColor: colors.backgroundColor,  // Set the dialog background color to match theme
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Username section
            Text(
              'Username',
              style: TextStyle(
                fontSize: 16,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    enabled: _isEditing,
                    style: TextStyle(color: colors.textColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: colors.cardBackground,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: colors.textColor,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Stats section
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 16,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Games\nPlayed', currentStats.gamesPlayed.toString()),
                _buildStatBox('Games\nWon', currentStats.gamesWon.toString()),
                _buildStatBox('Avg.\nAttempts', currentStats.avgAttempts.toStringAsFixed(1)),
              ],
            ),

            const SizedBox(height: 32),
            
            // Reset button
            Center(
              child: TextButton(
                onPressed: _resetAllData,
                style: TextButton.styleFrom(
                  foregroundColor: WordleColors.important,
                ),
                child: const Text('Reset All Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? WordleColors.darkTheme
        : WordleColors.lightTheme;

    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}