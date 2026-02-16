import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list_problem.dart';
import 'package:sqflite/sqlite_api.dart';

class ProblemListProblemRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<int> add(ProblemListProblem problemlListProblem) async {
    final db = await _dbProvider.database;
    return db.insert(
      'problem_list_problem',
      problemlListProblem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> remove(int problemId, int problemListId) async {
    final db = await _dbProvider.database;
    return db.delete(
      'problem_list_problem',
      where: 'problem_id = ? AND problem_list_id = ?',
      whereArgs: [problemId, problemListId],
    );
  }

  Future<List<Problem>> getByList(int problemListId) async {
    final db = await _dbProvider.database;
    final data = await db.rawQuery(
      '''
        SELECT p.*
        FROM problem p
        INNER JOIN problem_list_problem plp ON p.id = plp.problem_id
        WHERE plp.problem_list_id = ? 
      ''',
      [problemListId],
    );

    return data.map(Problem.fromJson).toList();
  }
}
