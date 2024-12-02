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
        title: const Text('¿Quieres restablecer tus datos?'),
        content: const Text(
          'Esto eliminará tu usuario y tus estadísticas. Esta acción no es reversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentStats = UserStats(username: 'Jugador');
                _usernameController.text = 'Jugador';
              });
              widget.onStatsUpdated(currentStats);
              Navigator.pop(context);
            },
            child: const Text(
              'Restablecer',
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
        const SnackBar(content: Text('El nombre de usuario no puede estar vacío.')),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
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
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Username section
            Text(
              'Nombre de usuario',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
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
              'Estadísticas',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Partidas\njugadas', currentStats.gamesPlayed.toString()),
                _buildStatBox('Partidas\nganadas', currentStats.gamesWon.toString()),
                _buildStatBox('Media de\nintentos', currentStats.avgAttempts.toStringAsFixed(1)),
              ],
            ),

            const SizedBox(height: 32),
            
            // Reset button
            Center(
              child: TextButton(
                onPressed: _resetAllData,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Restablecer tus datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}