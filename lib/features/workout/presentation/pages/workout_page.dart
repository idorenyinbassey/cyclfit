import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../shared/providers/workout_data_provider.dart';
import '../../../../shared/services/location_service.dart';
import '../../../../shared/providers/workout_provider.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  bool _isTracking = false;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  double _currentSpeed = 0.0;
  double _distance = 0.0;
  double _calories = 0.0;
  int _heartRate = 0;
  String _workoutType = 'leisure';
  final List<LatLng> _routePoints = [];
  LatLng? _lastPoint;
  DateTime? _lastGpsUpdate;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _accelMagnitude = 0.0;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _timer?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      _startWorkout();
    } else {
      _pauseWorkout();
    }
  }

  void _startWorkout() {
    // Persist session start in DB
    final sessionProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    sessionProvider.startSession(workoutType: _workoutType);
    // Start sensors
    _startSensors();
    // Start GPS tracking
    final loc = Provider.of<LocationService>(context, listen: false);
    loc.startTracking();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);

        // Update from GPS when available
        final pos = loc.currentPosition;
        if (pos != null) {
          final p = LatLng(pos.latitude, pos.longitude);
          if (_routePoints.isEmpty || _routePoints.last != p) {
            _routePoints.add(p);
            _mapMaybeFollow(p);
          }
          if (_lastPoint != null) {
            final meters = LocationService.calculateDistance(
              _lastPoint!.latitude,
              _lastPoint!.longitude,
              p.latitude,
              p.longitude,
            );
            if (meters.isFinite && meters >= 0) {
              _distance += meters / 1000.0; // km
            }
            final dt = _lastGpsUpdate != null
                ? DateTime.now().difference(_lastGpsUpdate!).inSeconds
                : 1;
            if (dt > 0) {
              _currentSpeed = (meters / dt) * 3.6; // m/s -> km/h
            }
          }
          _lastPoint = p;
          _lastGpsUpdate = DateTime.now();
        } else {
          // Fallback: light simulation influenced by accelerometer
          if (_isTracking && _elapsedTime.inSeconds % 3 == 0) {
            final accelFactor = (_accelMagnitude.clamp(0, 15)) / 15.0;
            _currentSpeed = 10.0 + 15.0 * accelFactor;
            _distance += _currentSpeed / 3600; // km
          }
        }

        _calories = _distance * 35; // Approximate calories per km
        _heartRate = 120 + (_currentSpeed * 0.8).toInt().clamp(0, 60);
      });
    });
  }

  void _pauseWorkout() {
    _timer?.cancel();
    setState(() {
      _currentSpeed = 0.0; // Stop showing speed when paused
    });
  }

  void _stopWorkout() {
    _timer?.cancel();
    final loc = Provider.of<LocationService>(context, listen: false);
    loc.stopTracking();
    _accelSub?.cancel();
    _showWorkoutSummary();
  }

  void _resetWorkout() {
    _timer?.cancel();
    setState(() {
      _isTracking = false;
      _elapsedTime = Duration.zero;
      _currentSpeed = 0.0;
      _distance = 0.0;
      _calories = 0.0;
      _heartRate = 0;
      _routePoints.clear();
      _lastPoint = null;
      _lastGpsUpdate = null;
    });
  }

  String get _formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(_elapsedTime.inHours);
    String minutes = twoDigits(_elapsedTime.inMinutes.remainder(60));
    String seconds = twoDigits(_elapsedTime.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showWorkoutSettings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWorkoutTypeSelector(),
            const SizedBox(height: 24),
            _buildMainMetrics(context),
            const SizedBox(height: 24),
            _buildSecondaryMetrics(context),
            const SizedBox(height: 24),
            _buildMapPlaceholder(context),
            const SizedBox(height: 24),
            _buildControlButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildWorkoutTypeChip(
                    'commute',
                    'Commute',
                    Icons.commute,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutTypeChip(
                    'training',
                    'Training',
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutTypeChip(
                    'leisure',
                    'Leisure',
                    Icons.park,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildWorkoutTypeChip('race', 'Race', Icons.flag, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTypeChip(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _workoutType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _workoutType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Time',
            _formattedTime,
            Icons.timer,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Speed',
            '${_currentSpeed.toStringAsFixed(1)} km/h',
            Icons.speed,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Distance',
            '${_distance.toStringAsFixed(2)} km',
            Icons.route,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Calories',
            '${_calories.toStringAsFixed(0)} cal',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _routePoints.isNotEmpty
                      ? _routePoints.last
                      : const LatLng(0, 0),
                  initialZoom: _routePoints.isNotEmpty ? 15 : 1,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.cyclfit.app',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: theme.colorScheme.primary,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _routePoints.last,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.pedal_bike,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (_heartRate > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_heartRate BPM',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isTracking
                        ? 'Recording route…'
                        : 'Start workout to track GPS',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _toggleTracking,
          icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
          label: Text(_isTracking ? 'Pause' : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTracking
                ? Colors.orange
                : Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        if (_isTracking || _elapsedTime.inSeconds > 0) ...[
          ElevatedButton.icon(
            onPressed: _stopWorkout,
            icon: const Icon(Icons.stop),
            label: const Text('Finish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _resetWorkout,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ],
    );
  }

  void _showWorkoutSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('GPS Accuracy'),
              subtitle: const Text('High (uses more battery)'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Heart Rate Monitor'),
              subtitle: const Text('Connect via Bluetooth'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Audio Cues'),
              subtitle: const Text('Every 1 km'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Great $_workoutType ride!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration:'),
                Text(
                  _formattedTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distance:'),
                Text(
                  '${_distance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Avg Speed:'),
                Text(
                  '${(_distance / (_elapsedTime.inSeconds / 3600)).toStringAsFixed(1)} km/h',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Calories:'),
                Text(
                  '${_calories.toStringAsFixed(0)} cal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '+25 CyclCoins earned!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetWorkout();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save workout to provider
              final workoutProvider = Provider.of<WorkoutDataProvider>(
                context,
                listen: false,
              );
              final sessionProvider = Provider.of<WorkoutProvider>(
                context,
                listen: false,
              );
              final averageSpeed = _elapsedTime.inSeconds > 0
                  ? _distance / (_elapsedTime.inSeconds / 3600)
                  : 0.0;

              final workout = WorkoutActivity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title:
                    '${_workoutType.substring(0, 1).toUpperCase()}${_workoutType.substring(1)} Ride',
                type: _workoutType,
                distance: _distance,
                duration: _elapsedTime,
                averageSpeed: averageSpeed,
                calories: _calories.toInt(),
                elevation: 50.0, // Mock elevation data
                date: DateTime.now(),
                routePoints: List<LatLng>.from(_routePoints),
                maxSpeed: _currentSpeed,
                avgHeartRate: _heartRate > 0 ? _heartRate.toDouble() : null,
              );

              workoutProvider.addWorkout(workout);

              // Finalize DB session
              sessionProvider.finalizeSession(
                calories: _calories,
                workoutType: _workoutType,
                avgHeartRate: _heartRate > 0 ? _heartRate : null,
                elevation: 50.0,
              );

              Navigator.of(context).pop();
              _resetWorkout();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout saved to history!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save Workout'),
          ),
        ],
      ),
    );
  }

  void _startSensors() {
    _accelSub?.cancel();
    _accelSub = accelerometerEventStream().listen((event) {
      // Basic magnitude to infer movement; low-pass filter could be added
      final mag = (event.x * event.x + event.y * event.y + event.z * event.z)
          .abs();
      // Normalize around ~9.8 m/s^2 gravity
      _accelMagnitude = (mag - 96.04).abs() / 96.04 * 9.8;
    });
  }

  void _mapMaybeFollow(LatLng p) {
    // Keep camera near the rider while tracking
    if (!_isTracking) return;
    try {
      _mapController.move(p, _mapController.camera.zoom);
    } catch (_) {}
  }
}
