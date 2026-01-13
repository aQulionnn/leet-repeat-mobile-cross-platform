import 'package:leet_repeat_mobile_cross_platform/data/database_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list.dart';

class ProblemListRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<int> add(ProblemList problemList) async {
    final db = await _dbProvider.database;
    return await db.insert('problem_list', problemList.toJson());
  }

  Future<List<ProblemList>> getAll() async {
    final db = await _dbProvider.database;
    final data = await db.query('problem_list');
    return data.map((e) => ProblemList.fromJson(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await _dbProvider.database;
    return db.delete(
      'problem_list',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}