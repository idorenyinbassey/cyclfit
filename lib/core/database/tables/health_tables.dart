import 'package:drift/drift.dart';

@DataClassName('HealthMetric')
class HealthMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().nullable()();
  TextColumn get metricType =>
      text()(); // 'blood_pressure', 'weight', 'heart_rate', etc.
  RealColumn get value => real()();
  RealColumn get secondaryValue =>
      real().nullable()(); // For blood pressure (diastolic)
  TextColumn get unit => text()(); // 'kg', 'mmHg', 'bpm', etc.
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
