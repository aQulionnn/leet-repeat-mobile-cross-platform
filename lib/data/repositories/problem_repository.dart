import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';

class ProblemRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<int> add(Problem problem) async {
    final db = await _dbProvider.database;
    return db.insert('problem', problem.toJson());
  }

  Future<List<Problem>> getAll() async {
    final db = await _dbProvider.database;
    final data = await db.query('problem');
    return data.map((e) => Problem.fromJson(e)).toList();
  }

  Future<Problem?> getById(int id) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      'problem',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return data.isEmpty ? null : Problem.fromJson(data.first);
  }

  Future<Problem?> getByQuestionId(int questionId) async {
    final db = await _dbProvider.database;
    final data = await db.query(
      'problem',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    return data.isEmpty ? null : Problem.fromJson(data.first);
  }

  Future<int> update(Problem problem) async {
    final db = await _dbProvider.database;
    return db.update(
      'problem',
      problem.toJson(),
      where: 'id = ?',
      whereArgs: [problem.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbProvider.database;
    return db.delete('problem', where: 'id = ?', whereArgs: [id]);
  }
}
