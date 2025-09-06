class AppConfig {
  // Supabase Configuration (replace with your own in app_config.dart)
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // The rest can mirror defaults; adjust as needed
  static const String databaseName = 'cyclfit.db';
  static const int databaseVersion = 1;
  static const String baseApiUrl = 'https://api.cyclfit.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double defaultMapZoom = 15.0;
  static const double maxMapZoom = 18.0;
  static const double minMapZoom = 3.0;
  static const double locationAccuracy = 5.0;
  static const int locationUpdateInterval = 5;
  static const double minDistanceForUpdate = 10.0;
  static const int maxWorkoutDuration = 8 * 60 * 60;
  static const double caloriesPerKmCycling = 25.0;
  static const int maxHeartRate = 220;
  static const int minHeartRate = 40;
  static const double maxWeightKg = 300.0;
  static const double minWeightKg = 30.0;
  static const int pointsPerKm = 10;
  static const int pointsPerWorkout = 50;
  static const int pointsPerDailyGoal = 100;
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024;
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundLocation = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;
}
