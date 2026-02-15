import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class GetProblemByQuestionIdResponse {
  final String question;
  final Difficulty difficulty;

  GetProblemByQuestionIdResponse({
    required this.question,
    required this.difficulty,
  });

  factory GetProblemByQuestionIdResponse.fromJson(Map<String, dynamic> json) {
    return GetProblemByQuestionIdResponse(
      question: '${json['questionFrontendId']}. ${json['title']}',
      difficulty: _mapDifficulty(json['difficulty']),
    );
  }

  static Difficulty _mapDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Difficulty.easy;
      case 'Medium':
        return Difficulty.medium;
      case 'Hard':
        return Difficulty.hard;
      default:
        throw Exception('Unknown difficulty');
    }
  }
}
