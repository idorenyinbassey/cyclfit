class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://bpgmkjpgavtsieefpdyz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwZ21ranBnYXZ0c2llZWZwZHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4MzYyMzIsImV4cCI6MjA3MjQxMjIzMn0.HlAuAF-V7DJk1j7Z0yRmSPYMAXxKQzTk0cahlp9cNeo';

  // Database Configuration
  static const String databaseName = 'cyclfit.db';
  static const int databaseVersion = 1;

  // API Configuration
  static const String baseApiUrl = 'https://api.cyclfit.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Map Configuration
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double defaultMapZoom = 15.0;
  static const double maxMapZoom = 18.0;
  static const double minMapZoom = 3.0;

  // Location Configuration
  static const double locationAccuracy = 5.0; // meters
  static const int locationUpdateInterval = 5; // seconds
  static const double minDistanceForUpdate = 10.0; // meters

  // Workout Configuration
  static const int maxWorkoutDuration = 8 * 60 * 60; // 8 hours in seconds
  static const double caloriesPerKmCycling =
      25.0; // approximate calories burned per km

  // Health Data Configuration
  static const int maxHeartRate = 220;
  static const int minHeartRate = 40;
  static const double maxWeightKg = 300.0;
  static const double minWeightKg = 30.0;

  // Gamification Configuration
  static const int pointsPerKm = 10;
  static const int pointsPerWorkout = 50;
  static const int pointsPerDailyGoal = 100;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundLocation = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false; // Set to false for privacy
}
