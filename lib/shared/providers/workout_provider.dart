import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final AppDatabase _database;
  final LocationService _locationService;
  final NotificationService _notificationService;

  WorkoutProvider({
    required AppDatabase database,
    required LocationService locationService,
    required NotificationService notificationService,
  }) : _database = database,
       _locationService = locationService,
       _notificationService = notificationService;

  bool _isWorkoutActive = false;
  bool get isWorkoutActive => _isWorkoutActive;

  int? _activeSessionId;
  DateTime? _activeStartTime;
  LatLng? _lastPoint;
  DateTime? _lastPointTime;
  double _distanceKm = 0.0;
  double _maxSpeed = 0.0;
  int _lastNotifiedKm = 0;
  Timer? _ticker;

  Future<int> startSession({
    required String workoutType,
    String? notes,
    String? userId,
  }) async {
    if (_isWorkoutActive) {
      return _activeSessionId!;
    }

    final id = await _database
        .into(_database.workoutSessions)
        .insert(
          WorkoutSessionsCompanion.insert(
            userId: Value(userId),
            startTime: DateTime.now(),
            workoutType: Value(workoutType),
            notes: Value(notes),
            isActive: const Value(true),
          ),
        );
    _activeSessionId = id;
    _activeStartTime = DateTime.now();
    _isWorkoutActive = true;
    _distanceKm = 0.0;
    _maxSpeed = 0.0;
    _lastNotifiedKm = 0;
    _lastPoint = null;
    _lastPointTime = null;

    // Start location tracking
    await _locationService.startTracking();
    // Periodic ticker to read latest position and persist route points
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!_isWorkoutActive || _activeSessionId == null) {
        t.cancel();
        return;
      }
      final pos = _locationService.currentPosition;
      if (pos == null) return;
      final p = LatLng(pos.latitude, pos.longitude);
      final now = DateTime.now();

      // distance and speed
      double meters = 0.0;
      if (_lastPoint != null) {
        meters = LocationService.calculateDistance(
          _lastPoint!.latitude,
          _lastPoint!.longitude,
          p.latitude,
          p.longitude,
        );
        if (meters.isFinite && meters >= 0) {
          _distanceKm += meters / 1000.0;
        }
        final dt = _lastPointTime != null
            ? now.difference(_lastPointTime!).inMilliseconds / 1000.0
            : 1.0;
        if (dt > 0) {
          final kmh = (meters / dt) * 3.6;
          if (kmh > _maxSpeed) _maxSpeed = kmh;
        }
      }
      _lastPoint = p;
      _lastPointTime = now;

      // insert route point
      await _database
          .into(_database.routePoints)
          .insert(
            RoutePointsCompanion.insert(
              workoutSessionId: _activeSessionId!,
              latitude: p.latitude,
              longitude: p.longitude,
              altitude: Value(pos.altitude.isFinite ? pos.altitude : null),
              speed: Value(pos.speed.isFinite ? pos.speed * 3.6 : 0.0),
              accuracy: Value(pos.accuracy.isFinite ? pos.accuracy : null),
              timestamp: now,
            ),
          );

      // milestone notifications at each whole km
      final kmFloor = _distanceKm.floor();
      if (kmFloor > 0 && kmFloor > _lastNotifiedKm) {
        _lastNotifiedKm = kmFloor;
        _notificationService.showWorkoutNotification(
          title: 'Distance Update',
          body: '$kmFloor km completed',
        );
      }
    });

    notifyListeners();
    return id;
  }

  Future<void> addManualRoutePoint({
    required double latitude,
    required double longitude,
    double? altitude,
    double? speedKmh,
    double? accuracy,
    DateTime? timestamp,
  }) async {
    if (!_isWorkoutActive || _activeSessionId == null) return;
    final now = timestamp ?? DateTime.now();
    await _database
        .into(_database.routePoints)
        .insert(
          RoutePointsCompanion.insert(
            workoutSessionId: _activeSessionId!,
            latitude: latitude,
            longitude: longitude,
            altitude: Value(altitude),
            speed: Value(speedKmh ?? 0.0),
            accuracy: Value(accuracy),
            timestamp: now,
          ),
        );
  }

  Future<int?> finalizeSession({
    required double calories,
    required String workoutType,
    int? avgHeartRate,
    double? elevation,
  }) async {
    if (!_isWorkoutActive || _activeSessionId == null) return _activeSessionId;

    _ticker?.cancel();
    _locationService.stopTracking();

    final end = DateTime.now();
    final durationSec = end.difference(_activeStartTime ?? end).inSeconds;
    final avgSpeed = durationSec > 0 ? _distanceKm / (durationSec / 3600) : 0.0;

    await (_database.update(
      _database.workoutSessions,
    )..where((tbl) => tbl.id.equals(_activeSessionId!))).write(
      WorkoutSessionsCompanion(
        endTime: Value(end),
        distance: Value(_distanceKm),
        duration: Value(durationSec),
        averageSpeed: Value(avgSpeed),
        maxSpeed: Value(_maxSpeed),
        calories: Value(calories),
        elevation: Value(elevation ?? 0.0),
        averageHeartRate: Value(avgHeartRate),
        workoutType: Value(workoutType),
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );

    _isWorkoutActive = false;
    final finishedId = _activeSessionId;
    _activeSessionId = null;
    notifyListeners();
    return finishedId;
  }

  Future<void> discardActiveSession() async {
    if (_activeSessionId == null) return;
    _ticker?.cancel();
    _locationService.stopTracking();
    await (_database.delete(
      _database.workoutSessions,
    )..where((tbl) => tbl.id.equals(_activeSessionId!))).go();
    _activeSessionId = null;
    _isWorkoutActive = false;
    notifyListeners();
  }

  // History: watch recent sessions from the database
  Stream<List<WorkoutSession>> watchRecentSessions({int limit = 100}) {
    final query = (_database.select(_database.workoutSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(limit));
    return query.watch();
  }

  Future<List<WorkoutSession>> getRecentSessions({int limit = 100}) {
    final query = (_database.select(_database.workoutSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(limit));
    return query.get();
  }

  // Watch a single session by id
  Stream<WorkoutSession?> watchSession(int id) {
    final q = _database.select(_database.workoutSessions)
      ..where((t) => t.id.equals(id));
    return q.watchSingleOrNull();
  }

  // Route points for a session
  Stream<List<RoutePoint>> watchRoutePoints(int sessionId) {
    final q = (_database.select(_database.routePoints)
      ..where((t) => t.workoutSessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]));
    return q.watch();
  }

  Future<List<RoutePoint>> getRoutePoints(int sessionId) {
    final q = (_database.select(_database.routePoints)
      ..where((t) => t.workoutSessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]));
    return q.get();
  }

  // Delete a session (route points will cascade delete)
  Future<void> deleteSession(int id) async {
    await (_database.delete(
      _database.workoutSessions,
    )..where((tbl) => tbl.id.equals(id))).go();
    notifyListeners();
  }

  // Update editable fields of a session
  Future<void> updateSession(
    int id, {
    String? workoutType,
    String? notes,
  }) async {
    final comp = WorkoutSessionsCompanion(
      workoutType: workoutType != null
          ? Value(workoutType)
          : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    await (_database.update(
      _database.workoutSessions,
    )..where((tbl) => tbl.id.equals(id))).write(comp);
    notifyListeners();
  }

  // Filtered list with basic pagination (limit/offset)
  Stream<List<WorkoutSession>> watchSessionsFiltered({
    String? type,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) {
    final sel = _database.select(_database.workoutSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(limit, offset: offset);
    if (type != null && type.isNotEmpty && type != 'all') {
      sel.where((t) => t.workoutType.equals(type));
    }
    if (from != null && to != null) {
      sel.where((t) => t.startTime.isBetween(Variable(from), Variable(to)));
    } else {
      if (from != null) {
        sel.where((t) => t.startTime.isBiggerOrEqual(Variable(from)));
      }
      if (to != null) {
        sel.where((t) => t.startTime.isSmallerOrEqual(Variable(to)));
      }
    }
    return sel.watch();
  }
}
