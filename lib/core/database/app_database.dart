import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/workout_tables.dart';
import 'tables/health_tables.dart';
import 'tables/user_tables.dart';
import 'tables/challenge_tables.dart';
import 'tables/blog_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    WorkoutSessions,
    RoutePoints,
    HealthMetrics,
    UserProfiles,
    UserPreferences,
    Challenges,
    UserChallenges,
    Articles,
    CachedArticles,
    Achievements,
    UserAchievements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // Insert default data
      await _insertDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migration to v2: add helpful indexes for offline performance
      if (from < 2) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workout_user_created ON workout_sessions(user_id, created_at)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workout_synced ON workout_sessions(is_synced)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workout_active ON workout_sessions(is_active)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workout_start ON workout_sessions(start_time)',
        );

        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_route_session_time ON route_points(workout_session_id, timestamp)',
        );

        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_health_user_time ON health_metrics(user_id, recorded_at)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_health_type_time ON health_metrics(metric_type, recorded_at)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_health_synced ON health_metrics(is_synced)',
        );

        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_articles_published_date ON articles(is_published, publish_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_articles_category ON articles(category)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cache_article_time ON cached_articles(article_id, cached_at)',
        );

        // Ensure uniqueness of user preferences by (user_id, key)
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_pref_user_key_unique ON user_preferences(user_id, key)',
        );
      }
    },
  );

  Future<void> _insertDefaultData() async {
    // Insert default challenges
    await batch((batch) {
      batch.insertAll(challenges, [
        ChallengesCompanion.insert(
          title: 'First Ride',
          description: 'Complete your first workout',
          type: 'distance',
          targetValue: 1.0,
          rewardPoints: 100,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
        ChallengesCompanion.insert(
          title: 'Weekly Warrior',
          description: 'Ride 5 times this week',
          type: 'frequency',
          targetValue: 5.0,
          rewardPoints: 250,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        ),
        ChallengesCompanion.insert(
          title: 'Distance Master',
          description: 'Cover 50km in total',
          type: 'distance',
          targetValue: 50.0,
          rewardPoints: 500,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
      ]);

      // Insert default achievements
      batch.insertAll(achievements, [
        AchievementsCompanion.insert(
          title: 'Speed Demon',
          description: 'Reach 30 km/h',
          badgeIcon: 'speed',
          unlockCriteria: 'max_speed:30',
          rewardPoints: 150,
        ),
        AchievementsCompanion.insert(
          title: 'Endurance Expert',
          description: 'Ride for 2 hours straight',
          badgeIcon: 'endurance',
          unlockCriteria: 'duration:7200',
          rewardPoints: 300,
        ),
        AchievementsCompanion.insert(
          title: 'Hill Climber',
          description: 'Climb 500m elevation',
          badgeIcon: 'mountain',
          unlockCriteria: 'elevation:500',
          rewardPoints: 200,
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cyclfit.db'));
    return NativeDatabase(file);
  });
}
