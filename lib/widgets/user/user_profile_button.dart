import 'package:flutter/material.dart';
import 'package:flutter_wordle/widgets/user/user_profile.dart';

class UserProfileButton extends StatelessWidget {
  final UserStats userStats;
  final Function(UserStats) onStatsUpdated;

  const UserProfileButton({
    super.key,
    required this.userStats,
    required this.onStatsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
    );
  }
}