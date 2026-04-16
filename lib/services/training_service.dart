import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../core/database/app_database.dart';
import '../core/providers/database_provider.dart';

final trainingServiceProvider = Provider<TrainingService>((ref) {
  return TrainingService(ref.watch(dbProvider));
});

class TrainingService {
  final AppDatabase _db;

  TrainingService(this._db);

  /// Synchronize lessons from network to local cache (mocked implementation)
  Future<void> syncLessons() async {
    final existingCount = await _db.select(_db.lessons).get();
    if (existingCount.isEmpty) {
      await _db
          .into(_db.lessons)
          .insert(
            LessonsCompanion.insert(
              category: 'Self Defense',
              title: 'Basic Escapes',
              content: 'Learn how to escape from wrist holds...',
            ),
          );
      await _db
          .into(_db.lessons)
          .insert(
            LessonsCompanion.insert(
              category: 'Awareness',
              title: 'Situational Awareness 101',
              content: 'Always identify exits and keep a clear view...',
            ),
          );
    }
  }

  /// Watch locally cached lessons for offline reading
  Stream<List<LessonEntry>> watchLessons() {
    return _db.select(_db.lessons).watch();
  }

  /// Mark a lesson as completed locally
  Future<void> completeLesson(int id) async {
    await (_db.update(_db.lessons)..where((l) => l.id.equals(id))).write(
      const LessonsCompanion(isCompleted: drift.Value(true)),
    );
  }
}
