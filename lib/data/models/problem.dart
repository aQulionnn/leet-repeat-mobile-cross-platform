import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class Problem {
  final int? id;
  final String question;
  final Difficulty difficulty;

  Problem({this.id, required this.question, required this.difficulty});

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'difficulty': difficulty.index,
  };

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
    id: json['id'],
    question: json['question'],
    difficulty: Difficulty.values[json['difficulty']],
  );
}