import 'package:flutter/material.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showChallengeInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCyclCoinsBalance(context),
            const SizedBox(height: 24),
            _buildActiveChallenges(context),
            const SizedBox(height: 24),
            _buildCompletedChallenges(context),
            const SizedBox(height: 24),
            _buildLeaderboard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclCoinsBalance(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.orange.shade100],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CyclCoins Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🪙 850 CyclCoins',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to rewards store
              },
              child: const Text('Spend'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallenges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Challenges',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          title: 'September Distance Goal',
          description: 'Ride 200km total this month',
          progress: 127.3,
          target: 200.0,
          unit: 'km',
          daysRemaining: 12,
          reward: '150 CyclCoins + Distance Champion Badge',
          motivation: "You're 64% there! Only 72.7km to go!",
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.route,
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          title: '5-Day Streak',
          description: 'Complete 5 rides in 5 consecutive days',
          progress: 3.0,
          target: 5.0,
          unit: 'days',
          currentStreak: 3,
          reward: '100 CyclCoins + Consistency Badge',
          motivation: 'Amazing! 3 days down, 2 to go!',
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildChallengeCard(
          context,
          title: 'Speed Demon',
          description: 'Achieve average speed of 25km/h on any ride',
          progress: 22.4,
          target: 25.0,
          unit: 'km/h',
          bestAttempt: '22.4 km/h',
          reward: '200 CyclCoins + Speed Demon Badge',
          motivation: 'So close! Just 2.6 km/h faster!',
          color: Theme.of(context).colorScheme.tertiary,
          icon: Icons.speed,
        ),
      ],
    );
  }

  Widget _buildCompletedChallenges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Completed',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildCompletedChallengeCard(
          context,
          title: 'First 50K',
          completionDate: 'Last Saturday',
          rewardEarned: '100 CyclCoins + Achievement Badge',
          celebration: '🎉 You crushed your first 50km ride!',
        ),
        const SizedBox(height: 8),
        _buildCompletedChallengeCard(
          context,
          title: 'Weekly Warrior',
          completionDate: '2 weeks ago',
          rewardEarned: '75 CyclCoins + Warrior Badge',
          celebration: '🏆 7 rides in 7 days - incredible dedication!',
        ),
      ],
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Distance Leaderboard',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLeaderboardItem(
                  context,
                  1,
                  'Alex Chen',
                  '342.8 km',
                  '🥇',
                ),
                const Divider(),
                _buildLeaderboardItem(
                  context,
                  2,
                  'Maria Santos',
                  '298.4 km',
                  '🥈',
                ),
                const Divider(),
                _buildLeaderboardItem(
                  context,
                  3,
                  'You',
                  '287.1 km',
                  '🥉',
                  isUser: true,
                ),
                const Divider(),
                _buildLeaderboardItem(context, 4, 'David Kim', '245.9 km', ''),
                const Divider(),
                _buildLeaderboardItem(
                  context,
                  5,
                  'Emma Wilson',
                  '234.7 km',
                  '',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(
    BuildContext context, {
    required String title,
    required String description,
    required double progress,
    required double target,
    required String unit,
    required String reward,
    required String motivation,
    required Color color,
    required IconData icon,
    int? daysRemaining,
    int? currentStreak,
    String? bestAttempt,
  }) {
    final progressPercentage = (progress / target).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (daysRemaining != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$daysRemaining days left',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(progressPercentage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reward,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              motivation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedChallengeCard(
    BuildContext context, {
    required String title,
    required String completionDate,
    required String rewardEarned,
    required String celebration,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Completed $completionDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    celebration,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rewardEarned,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    int rank,
    String name,
    String distance,
    String badge, {
    bool isUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isUser
          ? BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (badge.isNotEmpty) ...[
            Text(badge, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            distance,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUser ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showChallengeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Challenges Work'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 Join challenges to earn CyclCoins and badges!'),
              SizedBox(height: 12),
              Text('Ways to earn CyclCoins:'),
              Text('• Complete daily challenges (+25 coins)'),
              Text('• Finish weekly goals (+100 coins)'),
              Text('• Achieve personal bests (+50 coins)'),
              Text('• Maintain riding streaks (+10 coins/day)'),
              Text('• Write ride reviews (+15 coins)'),
              SizedBox(height: 12),
              Text(
                'Use CyclCoins in the Rewards Store to unlock themes, premium features, and exclusive badges!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
