import 'package:drift/drift.dart';

@DataClassName('WorkoutSession')
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get distance => real().withDefault(const Constant(0.0))();
  IntColumn get duration =>
      integer().withDefault(const Constant(0))(); // in seconds
  RealColumn get averageSpeed => real().withDefault(const Constant(0.0))();
  RealColumn get maxSpeed => real().withDefault(const Constant(0.0))();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get elevation => real().withDefault(const Constant(0.0))();
  IntColumn get averageHeartRate => integer().nullable()();
  IntColumn get maxHeartRate => integer().nullable()();
  TextColumn get workoutType => text().withDefault(const Constant('cycling'))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('RoutePoint')
class RoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutSessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().withDefault(const Constant(0.0))();
  RealColumn get accuracy => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
