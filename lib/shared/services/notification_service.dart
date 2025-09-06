import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends ChangeNotifier {
  bool _isInitialized = false;
  bool _hasPermission = false;
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;

  // Initialize notification service
  Future<void> initialize() async {
    try {
      await _requestPermission();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize notifications: $e';
      notifyListeners();
    }
  }

  // Request notification permission
  Future<bool> _requestPermission() async {
    try {
      final status = await Permission.notification.request();
      _hasPermission = status == PermissionStatus.granted;
      
      if (!_hasPermission) {
        _errorMessage = 'Notification permission denied';
      }
      
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      _errorMessage = 'Failed to request notification permission: $e';
      _hasPermission = false;
      notifyListeners();
      return false;
    }
  }

  // Show local notification (simplified version)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_hasPermission) {
      debugPrint('No notification permission');
      return;
    }

    // In a real app, you would use flutter_local_notifications
    // For now, we'll just log the notification
    debugPrint('Notification: $title - $body');
  }

  // Show workout notification
  Future<void> showWorkoutNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      title: title,
      body: body,
      payload: 'workout',
    );
  }

  // Show challenge notification
  Future<void> showChallengeNotification({
    required String title,
    required String body,
    int? challengeId,
  }) async {
    await showNotification(
      title: title,
      body: body,
      payload: 'challenge_$challengeId',
    );
  }

  // Show achievement notification
  Future<void> showAchievementNotification({
    required String title,
    required String body,
    int? achievementId,
  }) async {
    await showNotification(
      title: title,
      body: body,
      payload: 'achievement_$achievementId',
    );
  }

  // Schedule reminder notification
  Future<void> scheduleWorkoutReminder({
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    if (!_hasPermission) return;

    // In a real app, you would schedule the notification
    debugPrint('Scheduled notification for $scheduledTime: $title - $body');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // In a real app, you would cancel all scheduled notifications
    debugPrint('All notifications cancelled');
  }

  // Cancel notification by id
  Future<void> cancelNotification(int id) async {
    // In a real app, you would cancel specific notification
    debugPrint('Notification $id cancelled');
  }

  // Request permission explicitly
  Future<bool> requestPermission() async {
    return await _requestPermission();
  }

  // Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
