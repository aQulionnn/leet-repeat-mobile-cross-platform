import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/get_problem_by_question_id_response.dart';

class QuestionDetailResponse {
  final int questionId;
  final String title;
  final Difficulty difficulty;

  QuestionDetailResponse({
    required this.questionId,
    required this.title,
    required this.difficulty,
  });

  factory QuestionDetailResponse.fromJson(Map<String, dynamic> json) =>
      QuestionDetailResponse(
        questionId: int.parse(json['questionId']),
        title: json['title'],
        difficulty: GetProblemByQuestionIdResponse.mapDifficulty(json['difficulty']),
      );
}