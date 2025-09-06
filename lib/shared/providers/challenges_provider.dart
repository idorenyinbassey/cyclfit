import 'package:flutter/foundation.dart';
import '../../core/database/app_database.dart';
import '../services/notification_service.dart';

class ChallengesProvider extends ChangeNotifier {
  final AppDatabase _database;
  final NotificationService _notificationService;

  ChallengesProvider({
    required AppDatabase database,
    required NotificationService notificationService,
  })  : _database = database,
        _notificationService = notificationService;
}
