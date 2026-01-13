import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';

class ProgressRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<Progress?> getByProblemAndList(
    int problemId,
    int problemListId,
  ) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      'progress',
      where: 'problem_id = ? AND problem_list_id = ?',
      whereArgs: [problemId, problemListId],
      limit: 1,
    );

    return data.isEmpty ? null : Progress.fromJson(data.first);
  }

  Future<int> upsert(Progress progress) async {
    final db = await _dbProvider.database;

    if (progress.id == null) {
      return db.insert('progress', progress.toJson());
    }

    return db.update(
      'progress',
      progress.toJson(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<List<Progress>> getDueForReview(String nowIso) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      'progress',
      where: 'next_review_at <= ?',
      whereArgs: [nowIso],
    );

    return data.map(Progress.fromJson).toList();
  }
}
