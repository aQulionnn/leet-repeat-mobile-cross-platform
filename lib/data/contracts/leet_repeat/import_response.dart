import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';

class ImportResponse {
  final int id;
  final PerceivedDifficulty perceivedDifficulty;
  final Status status;
  final String? lastSolvedAtUtc;
  final String? nextReviewAtUtc;
  final int problemQuestionId;
  final String problemQuestion;
  final Difficulty problemDifficulty;
  final String problemListName;
  final String? username;
  final List<ImportProgressEvent> events;

  ImportResponse({
    required this.id,
    required this.perceivedDifficulty,
    required this.status,
    required this.lastSolvedAtUtc,
    required this.nextReviewAtUtc,
    required this.problemQuestionId,
    required this.problemQuestion,
    required this.problemDifficulty,
    required this.problemListName,
    this.username,
    required this.events,
  });

  factory ImportResponse.fromJson(Map<String, dynamic> json) => ImportResponse(
    id: json['id'],
    perceivedDifficulty:
        PerceivedDifficulty.values[json['perceived_difficulty']],
    status: Status.values[json['status']],
    lastSolvedAtUtc: json['last_solved_at_utc'],
    nextReviewAtUtc: json['next_review_at_utc'],
    problemQuestionId: json['problem_question_id'],
    problemQuestion: json['problem_question'],
    problemDifficulty: Difficulty.values[json['problem_difficulty']],
    problemListName: json['problem_list_name'],
    username: json['username'],
    events: (json['events'] as List? ?? [])
        .map((e) => ImportProgressEvent.fromJson(e))
        .toList(),
  );
}

class ImportProgressEvent {
  final int perceivedDifficulty;
  final String? solvedAtUtc;

  ImportProgressEvent({
    required this.perceivedDifficulty,
    required this.solvedAtUtc,
  });

  factory ImportProgressEvent.fromJson(Map<String, dynamic> json) =>
      ImportProgressEvent(
        perceivedDifficulty: json['perceived_difficulty'],
        solvedAtUtc: json['solved_at_utc'],
      );
}
