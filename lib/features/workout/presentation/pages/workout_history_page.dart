import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/providers/workout_provider.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  String _type = 'all';
  DateTime? _from;
  DateTime? _to;
  int _page = 0;
  static const int _pageSize = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildFilters(context),
              Expanded(
                child: StreamBuilder<List<WorkoutSession>>(
                  stream: provider.watchSessionsFiltered(
                    type: _type,
                    from: _from,
                    to: _to,
                    limit: _pageSize,
                    offset: _page * _pageSize,
                  ),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? const <WorkoutSession>[];
                    if (sessions.isEmpty) return _buildEmpty(context);

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = sessions[index];
                        return Dismissible(
                          key: ValueKey('sess-${s.id}'),
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.red.withOpacity(0.8),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) => provider.deleteSession(s.id),
                          child: Card(
                            child: ListTile(
                              onTap: () => context.push(
                                '${AppRouter.workout}/detail/${s.id}',
                              ),
                              leading: CircleAvatar(
                                backgroundColor: _typeColor(
                                  s.workoutType,
                                ).withOpacity(0.15),
                                child: Icon(
                                  _typeIcon(s.workoutType),
                                  color: _typeColor(s.workoutType),
                                ),
                              ),
                              title: Text(_titleFromType(s.workoutType)),
                              subtitle: Text(
                                '${s.distance.toStringAsFixed(2)} km • ${(s.duration / 60).toStringAsFixed(0)} min • ${s.averageSpeed.toStringAsFixed(1)} km/h\n'
                                '${_formatDate(s.startTime)}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'delete') {
                                    final ok = await _confirmDelete(context);
                                    if (ok) {
                                      await provider.deleteSession(s.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Session deleted'),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildPager(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'cycling', child: Text('Cycling')),
                DropdownMenuItem(value: 'commute', child: Text('Commute')),
                DropdownMenuItem(value: 'training', child: Text('Training')),
                DropdownMenuItem(value: 'race', child: Text('Race')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'all'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 2),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: _from != null && _to != null
                      ? DateTimeRange(start: _from!, end: _to!)
                      : null,
                );
                if (range != null) {
                  setState(() {
                    _from = DateTime(
                      range.start.year,
                      range.start.month,
                      range.start.day,
                    );
                    _to = DateTime(
                      range.end.year,
                      range.end.month,
                      range.end.day,
                      23,
                      59,
                      59,
                    );
                    _page = 0;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                _from == null
                    ? 'Any dates'
                    : '${_from!.year}-${_from!.month.toString().padLeft(2, '0')}-${_from!.day.toString().padLeft(2, '0')} → ${_to!.year}-${_to!.month.toString().padLeft(2, '0')}-${_to!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Clear filters',
            onPressed: () => setState(() {
              _type = 'all';
              _from = null;
              _to = null;
              _page = 0;
            }),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
    );
  }

  Widget _buildPager(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${_page + 1}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: _page > 0
                    ? () => setState(() => _page = _page - 1)
                    : null,
                child: const Text('Prev'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _page = _page + 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This will remove the workout and its route.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No workouts yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Start a live workout to begin building your history.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'commute':
        return Icons.commute;
      case 'training':
        return Icons.fitness_center;
      case 'race':
        return Icons.flag;
      default:
        return Icons.pedal_bike;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'commute':
        return Colors.blue;
      case 'training':
        return Colors.orange;
      case 'race':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  $h:$m';
  }

  String _titleFromType(String type) {
    final t = type.isNotEmpty
        ? type[0].toUpperCase() + type.substring(1)
        : 'Ride';
    return '$t Ride';
  }
}
