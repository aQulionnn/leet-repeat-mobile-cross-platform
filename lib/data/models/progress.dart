import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';

class Progress {
  int? id;
  PerceivedDifficulty perceivedDifficulty;
  String lastSolvedAtUtc;
  String? nextReviewAtUtc;
  Status status;
  int problemId;
  int problemListId;

  Progress({
    this.id,
    required this.perceivedDifficulty,
    required this.lastSolvedAtUtc,
    required this.nextReviewAtUtc,
    required this.status,
    required this.problemId,
    required this.problemListId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'perceived_difficulty': perceivedDifficulty.index,
    'last_solved_at_utc': lastSolvedAtUtc,
    'next_review_at_utc': nextReviewAtUtc,
    'status': status.index,
    'problem_id': problemId,
    'problem_list_id': problemListId,
  };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    id: json['id'],
    perceivedDifficulty:
        PerceivedDifficulty.values[json['perceived_difficulty']],
    lastSolvedAtUtc: json['last_solved_at_utc'],
    nextReviewAtUtc: json['next_review_at_utc'],
    status: Status.values[json['status']],
    problemId: json['problem_id'],
    problemListId: json['problem_list_id'],
  );
}