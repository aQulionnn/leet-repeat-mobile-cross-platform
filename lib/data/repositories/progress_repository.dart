import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/dtos/due_for_review_dto.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    int id;

    if (progress.id == null) {
      id = await db.insert('progress', progress.toJson());
    } else {
      await db.update(
        'progress',
        progress.toJson(),
        where: 'id = ?',
        whereArgs: [progress.id],
      );
      id = progress.id!;
    }

    await db.insert('progress_event', {
      'progress_id': id,
      'perceived_difficulty': progress.perceivedDifficulty.index,
      'solved_at_utc': progress.lastSolvedAtUtc,
    });

    return id;
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

  Future<List<DueForReviewDto>> getAllForExport() async {
    final db = await _dbProvider.database;

    final rows = await db.rawQuery('''
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
      WHERE pr.last_synced_at_utc IS NULL OR pr.last_solved_at_utc > pr.last_synced_at_utc
    ''');

    return rows.map(DueForReviewDto.fromMap).toList();
  }

  Future<void> markAsSynced(List<int> progressIds) async {
    final db = await _dbProvider.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.execute(
      'UPDATE progress SET last_synced_at_utc = ? WHERE id IN (${progressIds.map((_) => '?').join(',')})',
      [now, ...progressIds],
    );
  }

  // ProgressRepository
  Future<List<ProgressEvent>> getEvents(int progressId) async {
    final db = await _dbProvider.database;
    final rows = await db.query(
      'progress_event',
      where: 'progress_id = ?',
      whereArgs: [progressId],
      orderBy: 'solved_at_utc DESC',
    );
    return rows.map(ProgressEvent.fromJson).toList();
  }
}
