import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class Problem {
  final int? id;
  final int questionId;
  final String question;
  final Difficulty difficulty;

  Problem({
    this.id,
    required this.questionId,
    required this.question,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question_id': questionId,
    'question': question,
    'difficulty': difficulty.index,
  };

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
    id: json['id'],
    questionId: json['question_id'],
    question: json['question'],
    difficulty: Difficulty.values[json['difficulty']],
  );
}
