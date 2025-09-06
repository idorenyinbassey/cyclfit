import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/workout_provider.dart';
import '../../../../core/database/app_database.dart';

class WorkoutDetailPage extends StatelessWidget {
  final int sessionId;
  const WorkoutDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          IconButton(
            tooltip: 'Delete session',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete session?'),
                  content: const Text(
                    'This will permanently remove the workout and its route.',
                  ),
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
              if (ok == true) {
                await Provider.of<WorkoutProvider>(
                  context,
                  listen: false,
                ).deleteSession(sessionId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: provider.watchSession(sessionId),
        builder: (context, snapshot) {
          final session = snapshot.data;
          if (session == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('Session not found'));
          }

          return Column(
            children: [
              _buildHeader(session),
              const SizedBox(height: 8),
              _RouteSummary(sessionId: sessionId),
              const SizedBox(height: 12),
              Expanded(child: _buildMap(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(WorkoutSession s) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.workoutType.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${(s.distance).toStringAsFixed(2)} km • ${(s.duration / 60).toStringAsFixed(0)} min',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${s.averageSpeed.toStringAsFixed(1)} km/h'),
              if (s.calories > 0) Text('${s.calories.toStringAsFixed(0)} cal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(WorkoutProvider provider) {
    return StreamBuilder(
      stream: provider.watchRoutePoints(sessionId),
      builder: (context, snapshot) {
        final points = snapshot.data ?? [];
        final latlngs = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false);
        final center = latlngs.isNotEmpty ? latlngs.last : const LatLng(0, 0);
        final zoom = latlngs.isNotEmpty ? 14.0 : 1.0;

        return FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.cyclfit.app',
            ),
            if (latlngs.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(points: latlngs, color: Colors.blue, strokeWidth: 4),
                ],
              ),
            if (latlngs.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: latlngs.first,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.flag, color: Colors.green),
                  ),
                  Marker(
                    point: latlngs.last,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.flag, color: Colors.red),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _RouteSummary extends StatelessWidget {
  final int sessionId;
  const _RouteSummary({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    return StreamBuilder<List<RoutePoint>>(
      stream: provider.watchRoutePoints(sessionId),
      builder: (context, snapshot) {
        final pts = snapshot.data ?? const <RoutePoint>[];
        if (pts.isEmpty) return const SizedBox.shrink();

        double gain = 0, loss = 0;
        for (int i = 1; i < pts.length; i++) {
          final a = pts[i - 1].altitude;
          final b = pts[i].altitude;
          if (a != null && b != null) {
            final diff = b - a;
            if (diff > 0)
              gain += diff;
            else
              loss += -diff;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _metric(Icons.timeline, 'Points', pts.length.toString()),
                  _metric(
                    Icons.trending_up,
                    'Elev. gain',
                    '${gain.toStringAsFixed(0)} m',
                  ),
                  _metric(
                    Icons.trending_down,
                    'Elev. loss',
                    '${loss.toStringAsFixed(0)} m',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _metric(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
