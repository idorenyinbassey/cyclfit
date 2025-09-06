import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class WorkoutDataProvider extends ChangeNotifier {
  // Weekly stats
  double _weeklyDistance = 0.0;
  int _weeklyRides = 0;
  Duration _weeklyTime = Duration.zero;
  int _weeklyCalories = 0;

  // Personal bests
  double _longestRide = 0.0;
  double _bestSpeed = 0.0;
  double _highestClimb = 0.0;

  // Recent activities
  final List<WorkoutActivity> _recentActivities = [];
  final List<WorkoutActivity> _allActivities = [];

  // Getters
  double get weeklyDistance => _weeklyDistance;
  int get weeklyRides => _weeklyRides;
  Duration get weeklyTime => _weeklyTime;
  int get weeklyCalories => _weeklyCalories;
  double get longestRide => _longestRide;
  double get bestSpeed => _bestSpeed;
  double get highestClimb => _highestClimb;
  List<WorkoutActivity> get recentActivities =>
      List.unmodifiable(_recentActivities);
  List<WorkoutActivity> get allActivities => List.unmodifiable(_allActivities);

  // Add workout data
  void addWorkout(WorkoutActivity activity) {
    // Keep a full history and a short recent list for home widgets
    _allActivities.insert(0, activity);
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 10) {
      _recentActivities.removeLast();
    }

    // Update weekly stats
    _weeklyDistance += activity.distance;
    _weeklyRides++;
    _weeklyTime = Duration(
      seconds: _weeklyTime.inSeconds + activity.duration.inSeconds,
    );
    _weeklyCalories += activity.calories;

    // Update personal bests
    if (activity.distance > _longestRide) {
      _longestRide = activity.distance;
    }
    if (activity.averageSpeed > _bestSpeed) {
      _bestSpeed = activity.averageSpeed;
    }
    if (activity.elevation > _highestClimb) {
      _highestClimb = activity.elevation;
    }

    notifyListeners();
  }

  // Reset weekly stats (call this every week)
  void resetWeeklyStats() {
    _weeklyDistance = 0.0;
    _weeklyRides = 0;
    _weeklyTime = Duration.zero;
    _weeklyCalories = 0;
    notifyListeners();
  }

  // Check if user has any workout data
  bool get hasWorkoutData => _recentActivities.isNotEmpty || _weeklyRides > 0;

  // Get formatted time string
  String get formattedWeeklyTime {
    final hours = _weeklyTime.inHours;
    final minutes = _weeklyTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class WorkoutActivity {
  final String id;
  final String title;
  final String type;
  final double distance;
  final Duration duration;
  final double averageSpeed;
  final int calories;
  final double elevation;
  final DateTime date;
  // An optional list of GPS points for this activity (if recorded)
  final List<LatLng> routePoints;
  // Optional stats captured during the workout
  final double? maxSpeed;
  final double? avgHeartRate;

  WorkoutActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.distance,
    required this.duration,
    required this.averageSpeed,
    required this.calories,
    required this.elevation,
    required this.date,
    this.routePoints = const [],
    this.maxSpeed,
    this.avgHeartRate,
  });

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedDistance => '${distance.toStringAsFixed(1)} km';
}
