import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/database/app_database.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/location_service.dart';
import 'auth_provider.dart';
import 'workout_provider.dart';
import 'health_provider.dart';
import 'blog_provider.dart';
import 'challenges_provider.dart';
import 'workout_data_provider.dart';
import 'weather_data_provider.dart';

class AppProviders {
  static List<ChangeNotifierProvider> providers({
    required AppDatabase database,
    required FlutterSecureStorage storage,
    required NotificationService notificationService,
    required LocationService locationService,
  }) {
    return [
      // Expose LocationService so widgets can read the current GPS position
      ChangeNotifierProvider<LocationService>.value(value: locationService),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(database: database, storage: storage),
      ),
      ChangeNotifierProvider<WorkoutProvider>(
        create: (_) => WorkoutProvider(
          database: database,
          locationService: locationService,
          notificationService: notificationService,
        ),
      ),
      ChangeNotifierProvider<HealthProvider>(
        create: (_) {
          final p = HealthProvider(database: database);
          // Preload saved health metrics from DB
          p.loadLatestMetrics();
          return p;
        },
      ),
      ChangeNotifierProvider<BlogProvider>(
        create: (_) => BlogProvider(database: database),
      ),
      ChangeNotifierProvider<ChallengesProvider>(
        create: (_) => ChallengesProvider(
          database: database,
          notificationService: notificationService,
        ),
      ),
      ChangeNotifierProvider<WorkoutDataProvider>(
        create: (_) => WorkoutDataProvider(),
      ),
      ChangeNotifierProvider<WeatherDataProvider>(
        create: (_) => WeatherDataProvider(),
      ),
    ];
  }
}
