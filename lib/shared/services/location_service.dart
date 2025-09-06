import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/config/app_config.dart';

class LocationService extends ChangeNotifier {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _hasPermission = false;
  String? _errorMessage;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;
  bool get isTracking => _positionStreamSubscription != null;

  // Initialize location service
  Future<void> initialize() async {
    await _checkLocationPermission();
    await _checkLocationService();

    if (_hasPermission && _isLocationEnabled) {
      await _getCurrentLocation();
    }
  }

  // Check and request location permission
  Future<bool> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied';
        _hasPermission = false;
        notifyListeners();
        return false;
      }

      _hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!_hasPermission) {
        _errorMessage = 'Location permission denied';
      }

      notifyListeners();
      return _hasPermission;
    } catch (e) {
      _errorMessage = 'Failed to check location permission: $e';
      _hasPermission = false;
      notifyListeners();
      return false;
    }
  }

  // Check if location service is enabled
  Future<bool> _checkLocationService() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();

      if (!_isLocationEnabled) {
        _errorMessage = 'Location services are disabled';
      }

      notifyListeners();
      return _isLocationEnabled;
    } catch (e) {
      _errorMessage = 'Failed to check location service: $e';
      _isLocationEnabled = false;
      notifyListeners();
      return false;
    }
  }

  // Get current location
  Future<Position?> _getCurrentLocation() async {
    if (!_hasPermission || !_isLocationEnabled) {
      return null;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _clearError();
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _errorMessage = 'Failed to get current location: $e';
      notifyListeners();
      return null;
    }
  }

  // Start location tracking
  Future<bool> startTracking() async {
    if (!_hasPermission || !_isLocationEnabled) {
      await initialize();
      if (!_hasPermission || !_isLocationEnabled) {
        return false;
      }
    }

    if (_positionStreamSubscription != null) {
      return true; // Already tracking
    }

    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConfig.minDistanceForUpdate.toInt(),
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              _currentPosition = position;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = 'Location tracking error: $error';
              notifyListeners();
            },
          );

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start location tracking: $e';
      notifyListeners();
      return false;
    }
  }

  // Stop location tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    notifyListeners();
  }

  // Calculate distance between two positions
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate bearing between two positions
  static double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Request location permission explicitly
  Future<bool> requestPermission() async {
    return await _checkLocationPermission();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  // Get location accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    return 'Poor';
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
