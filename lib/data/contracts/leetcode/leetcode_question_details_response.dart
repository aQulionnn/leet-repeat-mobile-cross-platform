import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class LeetCodeQuestionDetailsResponse {
  final String title;
  final Difficulty difficulty;

  LeetCodeQuestionDetailsResponse({
    required this.title,
    required this.difficulty,
  });

  factory LeetCodeQuestionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LeetCodeQuestionDetailsResponse(
      title: '${json['questionId']}. ${json['title']}',
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
