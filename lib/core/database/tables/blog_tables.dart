import 'package:drift/drift.dart';

@DataClassName('Article')
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get excerpt => text().nullable()();
  TextColumn get author => text()();
  TextColumn get category => text()();
  TextColumn get featuredImageUrl => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON string
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishDate => dateTime()();
  IntColumn get readTime =>
      integer().nullable()(); // estimated read time in minutes
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CachedArticle')
class CachedArticles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get articleId =>
      integer().references(Articles, #id, onDelete: KeyAction.cascade)();
  TextColumn get cachedContent => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime()();
}
