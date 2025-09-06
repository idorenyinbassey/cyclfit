import 'package:drift/drift.dart';

@DataClassName('UserProfile')
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  IntColumn get age => integer().nullable()();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  TextColumn get fitnessLevel =>
      text().withDefault(const Constant('beginner'))();
  TextColumn get profileImageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserPreference')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId =>
      text().references(UserProfiles, #userId, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Ensure a user can't have duplicate keys while keeping an auto-increment id
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {userId, key},
  ];
}
