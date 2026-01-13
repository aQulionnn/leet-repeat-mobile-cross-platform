import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';

class ProblemListProblemRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<int> add(int problemId, int problemListId) async {
    final db = await _dbProvider.database;
    return db.insert('problem_list_problem', {
      'problem_id': problemId,
      'problem_list_id': problemListId,
    });
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
      [problemListId]
    );

    return data.map(Problem.fromJson).toList();
  }
}