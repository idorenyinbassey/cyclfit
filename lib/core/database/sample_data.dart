import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'app_database.dart';

class SampleData {
  static Future<void> insertSampleData(AppDatabase database) async {
    // Sample workout sessions
    final sampleWorkouts = [
      WorkoutSessionsCompanion.insert(
        userId: const Value('demo_user'),
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: Value(
          DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        ),
        distance: const Value(15.5),
        duration: const Value(3600), // 1 hour
        averageSpeed: const Value(15.5),
        maxSpeed: const Value(28.3),
        calories: const Value(387.5),
        elevation: const Value(120.0),
        averageHeartRate: const Value(145),
        maxHeartRate: const Value(168),
        notes: const Value('Great morning ride through the park'),
      ),
      WorkoutSessionsCompanion.insert(
        userId: const Value('demo_user'),
        startTime: DateTime.now().subtract(const Duration(days: 3)),
        endTime: Value(
          DateTime.now().subtract(const Duration(days: 3, hours: -2)),
        ),
        distance: const Value(32.1),
        duration: const Value(7200), // 2 hours
        averageSpeed: const Value(16.05),
        maxSpeed: const Value(35.2),
        calories: const Value(802.5),
        elevation: const Value(450.0),
        averageHeartRate: const Value(152),
        maxHeartRate: const Value(178),
        notes: const Value('Long weekend ride with hills'),
      ),
    ];

    // Sample health metrics
    final sampleHealthMetrics = [
      HealthMetricsCompanion.insert(
        userId: const Value('demo_user'),
        metricType: 'weight',
        value: 75.5,
        unit: 'kg',
        recordedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HealthMetricsCompanion.insert(
        userId: const Value('demo_user'),
        metricType: 'blood_pressure',
        value: 120.0,
        unit: 'mmHg',
        secondaryValue: const Value(80.0),
        recordedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HealthMetricsCompanion.insert(
        userId: const Value('demo_user'),
        metricType: 'heart_rate',
        value: 72.0,
        unit: 'bpm',
        recordedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];

    // Sample blog articles
    final sampleArticles = [
      ArticlesCompanion.insert(
        title: 'Cycling Safety Tips',
        content: '''# Cycling Safety Tips

## Essential Safety Rules for Every Cyclist

Cycling is a fantastic way to stay fit and explore your surroundings, but safety should always be your top priority. Here are the essential safety tips every cyclist should follow:

### 1. Wear a Helmet
Always wear a properly fitted helmet.

### 2. Be Visible
- Wear bright, reflective clothing
- Use lights on your bike

### 3. Follow Traffic Rules
- Ride in the same direction as traffic
- Obey traffic signals and signs

### 4. Stay Alert
- Keep your eyes on the road
- Avoid using headphones

### 5. Maintain Your Bike
- Check tire pressure regularly
- Ensure brakes are working properly

Remember, safety is not just about protecting yourself – it's about being a responsible member of the road community.''',
        excerpt: const Value(
          'Learn the fundamental safety rules every cyclist should follow to stay safe on the road.',
        ),
        featuredImageUrl: const Value('https://example.com/cycling-safety.jpg'),
        category: 'safety',
        readTime: const Value(5),
        isPublished: const Value(true),
        author: 'Cyclfit Team',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ArticlesCompanion.insert(
        title: 'Building Cycling Endurance',
        content: '''# Building Cycling Endurance: A Complete Guide

## 12-Week Training Plan for Better Performance

Building cycling endurance takes time, patience, and a structured approach.

### Week 1-4: Base Building
Start with shorter rides focusing on consistency rather than intensity.

### Week 5-8: Building Intensity
Introduce interval training and hill work.

### Week 9-12: Peak Performance
Focus on race-specific training and maintaining fitness.

### Nutrition Tips
- Eat carbohydrates before long rides
- Hydrate consistently throughout training
- Include protein for muscle recovery

### Recovery
- Get adequate sleep (7-9 hours)
- Include rest days in your schedule
- Listen to your body

With consistent training and proper recovery, you'll see significant improvements in your cycling endurance within 12 weeks.''',
        excerpt: const Value(
          'A comprehensive 12-week training plan to build cycling endurance and improve performance.',
        ),
        featuredImageUrl: const Value(
          'https://example.com/endurance-training.jpg',
        ),
        category: 'training',
        readTime: const Value(8),
        isPublished: const Value(true),
        author: 'Cyclfit Team',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    try {
      // Insert sample data
      await database.batch((batch) {
        batch.insertAll(database.workoutSessions, sampleWorkouts);
        batch.insertAll(database.healthMetrics, sampleHealthMetrics);
        batch.insertAll(database.articles, sampleArticles);
      });

      debugPrint('Sample data inserted successfully');
    } catch (e) {
      debugPrint('Error inserting sample data: $e');
    }
  }
}
