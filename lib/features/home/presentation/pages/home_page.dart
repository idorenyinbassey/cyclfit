import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/workout_data_provider.dart';
import '../../../../shared/providers/workout_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/providers/weather_data_provider.dart';
import '../../../../shared/widgets/stats_card.dart';
import '../../../../shared/widgets/activity_tile.dart';
import '../../../../shared/widgets/weather_widget.dart';
import '../../../../shared/widgets/quick_action_button.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch weather data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final weatherProvider = Provider.of<WeatherDataProvider>(
        context,
        listen: false,
      );
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );

      final pos = locationService.currentPosition;
      if (pos != null) {
        // WeatherAPI supports lat,long as q parameter
        await weatherProvider.fetchWeatherData(
          location: '${pos.latitude},${pos.longitude}',
        );
      } else {
        await weatherProvider.fetchWeatherData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildWeatherWidget(),
                  const SizedBox(height: 24),
                  _buildWeeklyStats(context),
                  const SizedBox(height: 24),
                  _buildPersonalBests(context),
                  const SizedBox(height: 24),
                  _buildRecentActivities(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'CyclFit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push(AppRouter.profile),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.userProfile;
        final hour = DateTime.now().hour;

        String greeting;
        String emoji;

        if (hour < 12) {
          greeting =
              "Good morning, ${user?.name ?? 'Cyclist'}! Ready for today's ride?";
          emoji = "🌅";
        } else if (hour < 17) {
          greeting =
              "Good afternoon, ${user?.name ?? 'Cyclist'}! Perfect time for a cycling session.";
          emoji = "☀️";
        } else {
          greeting =
              "Good evening, ${user?.name ?? 'Cyclist'}! How about a sunset ride?";
          emoji = "🌅";
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        QuickActionButton(
          icon: Icons.play_circle_filled,
          label: 'Start Ride',
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.push(AppRouter.workout),
        ),
        QuickActionButton(
          icon: Icons.history,
          label: 'History',
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push(AppRouter.workoutHistory),
        ),
        QuickActionButton(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => context.push(AppRouter.health),
        ),
        QuickActionButton(
          icon: Icons.emoji_events_outlined,
          label: 'Challenges',
          color: Theme.of(context).colorScheme.error,
          onTap: () => context.push(AppRouter.challenges),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return Consumer<WeatherDataProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Loading weather data...'),
                ],
              ),
            ),
          );
        }

        return WeatherWidget(
          temperature: weatherProvider.temperature,
          condition: weatherProvider.condition,
          windSpeed: weatherProvider.windSpeed,
          uvIndex: weatherProvider.uvIndex,
          recommendation: weatherProvider.recommendation,
          location: weatherProvider.location,
          onRefresh: () async {
            final weather = Provider.of<WeatherDataProvider>(
              context,
              listen: false,
            );
            final loc = Provider.of<LocationService>(context, listen: false);
            final pos = loc.currentPosition;
            if (pos != null) {
              await weather.fetchWeatherData(
                location: '${pos.latitude},${pos.longitude}',
              );
            } else {
              await weather.fetchWeatherData();
            }
          },
        );
      },
    );
  }

  Widget _buildWeeklyStats(BuildContext context) {
    return Consumer<WorkoutDataProvider>(
      builder: (context, workoutProvider, child) {
        if (!workoutProvider.hasWorkoutData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_bike_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No rides this week yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your first ride to see your stats here!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Distance',
                    value:
                        '${workoutProvider.weeklyDistance.toStringAsFixed(1)} km',
                    icon: Icons.route,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsCard(
                    title: 'Rides',
                    value: '${workoutProvider.weeklyRides}',
                    icon: Icons.directions_bike,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Time',
                    value: workoutProvider.formattedWeeklyTime,
                    icon: Icons.timer,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatsCard(
                    title: 'Calories',
                    value: '${workoutProvider.weeklyCalories}',
                    icon: Icons.local_fire_department,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalBests(BuildContext context) {
    return Consumer<WorkoutDataProvider>(
      builder: (context, workoutProvider, child) {
        if (!workoutProvider.hasWorkoutData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Bests',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No personal bests yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete some rides to start tracking your achievements!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Bests',
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
                    if (workoutProvider.longestRide > 0) ...[
                      _buildPersonalBestItem(
                        context,
                        'Longest Ride',
                        '${workoutProvider.longestRide.toStringAsFixed(1)} km',
                        'Your record',
                        Icons.route,
                      ),
                      const Divider(),
                    ],
                    if (workoutProvider.bestSpeed > 0) ...[
                      _buildPersonalBestItem(
                        context,
                        'Best Speed',
                        '${workoutProvider.bestSpeed.toStringAsFixed(1)} km/h',
                        'Your fastest',
                        Icons.speed,
                      ),
                      const Divider(),
                    ],
                    if (workoutProvider.highestClimb > 0) ...[
                      _buildPersonalBestItem(
                        context,
                        'Highest Climb',
                        '${workoutProvider.highestClimb.toStringAsFixed(0)} m',
                        'Your biggest climb',
                        Icons.terrain,
                      ),
                    ],
                    if (workoutProvider.longestRide == 0 &&
                        workoutProvider.bestSpeed == 0 &&
                        workoutProvider.highestClimb == 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Start riding to set your first records!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalBestItem(
    BuildContext context,
    String label,
    String value,
    String date,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(AppRouter.workoutHistory),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<WorkoutSession>>(
              stream: provider.watchRecentSessions(limit: 3),
              builder: (context, snapshot) {
                final sessions = snapshot.data ?? const <WorkoutSession>[];
                if (sessions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recent activities',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your workout history will appear here after completing rides',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: sessions
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Stack(
                            children: [
                              ActivityTile(
                                onTap: () => context.push(
                                  '${AppRouter.workout}/detail/${s.id}',
                                ),
                                title: _titleFromType(s.workoutType),
                                subtitle: _formatDate(s.startTime),
                                distance: '${s.distance.toStringAsFixed(2)} km',
                                duration:
                                    '${(s.duration / 60).toStringAsFixed(0)} min',
                                route: s.distance > 0
                                    ? 'Route recorded'
                                    : 'No route',
                                type: s.workoutType,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      await _editSession(
                                        context,
                                        s.id,
                                        initialType: s.workoutType,
                                        initialNotes: s.notes ?? '',
                                      );
                                    } else if (v == 'delete') {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete session?'),
                                          content: const Text(
                                            'This will remove the workout and its route.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        await provider.deleteSession(s.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSession(
    BuildContext context,
    int id, {
    required String initialType,
    required String initialNotes,
  }) async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final typeController = TextEditingController(text: initialType);
    final notesController = TextEditingController(text: initialNotes);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.updateSession(
        id,
        workoutType: typeController.text.trim(),
        notes: notesController.text.trim(),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _titleFromType(String type) {
    final t = type.isNotEmpty
        ? type[0].toUpperCase() + type.substring(1)
        : 'Ride';
    return '$t Ride';
  }
}
