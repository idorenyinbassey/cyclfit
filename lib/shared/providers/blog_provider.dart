import 'package:flutter/foundation.dart';
import '../../core/database/app_database.dart';

class BlogProvider extends ChangeNotifier {
  final AppDatabase _database;

  BlogProvider({required AppDatabase database}) : _database = database;
}
