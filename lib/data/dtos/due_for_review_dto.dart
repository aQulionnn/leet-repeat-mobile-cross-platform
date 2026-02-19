import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';

class DueForReviewDto {
  final Progress progress;
  final Problem problem;
  final ProblemList problemList;

  DueForReviewDto({required this.progress, required this.problem, required this.problemList});

  factory DueForReviewDto.fromMap(Map<String, Object?> map) {
    return DueForReviewDto(
      progress: Progress.fromJson(map),
      problem: Problem(
        id: map['p_id'] as int?,
        questionId: map['p_question_id'] as int,
        question: map['p_question'] as String,
        difficulty: Difficulty.values[map['p_difficulty'] as int],
      ),
      problemList: ProblemList(
        id: map['pl_id'] as int?,
        name: map['pl_name'] as String
      )
    );
  }
}
