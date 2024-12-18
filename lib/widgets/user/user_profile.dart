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

  Map<String, dynamic> toJson() => {
    'username': username,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'avgAttempts': avgAttempts,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    username: json['username'] as String? ?? 'Jugador',
    gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    gamesWon: json['gamesWon'] as int? ?? 0,
    avgAttempts: (json['avgAttempts'] as num?)?.toDouble() ?? 0.0,
  );
}

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
  static const int maxUsernameLength = 20;
  static const String defaultUsername = 'Jugador';

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
    final colors = Theme.of(context).brightness == Brightness.dark
        ? WordleColors.darkTheme
        : WordleColors.lightTheme;
        
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        title: Text(
          '¿Quieres restablecer tus datos?',
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Esto eliminará tu usuario y tus estadísticas. Esta acción no es reversible.',
          style: TextStyle(
            color: colors.secondaryText,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          // Cancel button with default theme color
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.dialogButton,
              foregroundColor: colors.dialogButtonText,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Reset button with danger/red color
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStats = UserStats(username: 'Jugador');
                _usernameController.text = 'Jugador';
              });
              widget.onStatsUpdated(currentStats);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WordleColors.important,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Restablecer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final newUsername = _usernameController.text.trim().isEmpty 
        ? defaultUsername 
        : _usernameController.text.trim();
    
    setState(() {
      currentStats = UserStats(
        username: newUsername,
        gamesPlayed: currentStats.gamesPlayed,
        gamesWon: currentStats.gamesWon,
        avgAttempts: currentStats.avgAttempts,
      );
      _usernameController.text = newUsername;
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
      backgroundColor: colors.backgroundColor,
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
                  'Perfil',
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
            
            Text(
              'Nombre de usuario',
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
                    maxLength: maxUsernameLength,
                    cursorColor: colors.textColor, // Match cursor color to text color
                    style: TextStyle(
                      color: _isEditing ? colors.textColor : colors.secondaryText,
                    ),
                    decoration: InputDecoration(
                      counterText: '', // Hide the character counter
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isEditing ? colors.borderColor : colors.secondaryText,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder( // Add focused border styling
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colors.borderColor,
                          width: 2.0, // Slightly thicker border when focused
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colors.borderColor,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colors.secondaryText.withOpacity(0.5),
                        ),
                      ),
                      fillColor: _isEditing ? colors.cardBackground : colors.cardBackground.withOpacity(0.5),
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
            
            Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 16,
                color: colors.secondaryText,
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
            
            Center(
              child: ElevatedButton(
                onPressed: _resetAllData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WordleColors.important,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Restablecer tus datos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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