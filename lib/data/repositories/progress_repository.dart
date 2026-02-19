import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/dtos/due_for_review_dto.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
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

  Future<List<DueForReviewDto>> getDueForReview(String nowIso) async {
    final db = await _dbProvider.database;

    final rows = await db.rawQuery(
      '''
      SELECT 
        pr.*,
        p.id as p_id,
        p.question_id as p_question_id,
        p.question as p_question,
        p.difficulty as p_difficulty,
        pl.id as pl_id,
        pl.name as pl_name
      FROM progress pr
      JOIN problem p ON p.id = pr.problem_id
      JOIN problem_list pl ON pl.id = pr.problem_list_id
      WHERE pr.next_review_at_utc <= ? AND pr.status = ?
      ORDER BY next_review_at_utc ASC
      ''',
      [nowIso, Status.practicing.index],
    );

    return rows.map(DueForReviewDto.fromMap).toList();
  }
}
