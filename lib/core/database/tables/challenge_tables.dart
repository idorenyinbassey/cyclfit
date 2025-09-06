import 'package:drift/drift.dart';

@DataClassName('Challenge')
class Challenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()(); // 'distance', 'frequency', 'speed', 'elevation'
  RealColumn get targetValue => real()();
  IntColumn get rewardPoints => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get difficultyLevel => text().withDefault(const Constant('beginner'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserChallenge')
class UserChallenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get challengeId => integer().references(Challenges, #id, onDelete: KeyAction.cascade)();
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Achievement')
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get badgeIcon => text()();
  TextColumn get unlockCriteria => text()();
  IntColumn get rewardPoints => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserAchievement')
class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get achievementId => integer().references(Achievements, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
}
