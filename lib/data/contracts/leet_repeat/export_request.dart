class ExportRequest {
  final int perceivedDifficulty;
  final int status;
  final String? lastSolvedAtUtc;
  final String? nextReviewAtUtc;
  final int problemQuestionId;
  final String problemQuestion;
  final int problemDifficulty;
  final String problemListName;
  final String? username;
  final List<ExportProgressEvent> events;

  ExportRequest({
    required this.perceivedDifficulty,
    required this.status,
    required this.lastSolvedAtUtc,
    required this.nextReviewAtUtc,
    required this.problemQuestionId,
    required this.problemQuestion,
    required this.problemDifficulty,
    required this.problemListName,
    this.username,
    this.events = const [],
  });

  Map<String, dynamic> toJson() => {
    'perceivedDifficulty': perceivedDifficulty,
    'status': status,
    'lastSolvedAtUtc': lastSolvedAtUtc,
    'nextReviewAtUtc': nextReviewAtUtc,
    'problemQuestionId': problemQuestionId,
    'problemQuestion': problemQuestion,
    'problemDifficulty': problemDifficulty,
    'problemListName': problemListName,
    'username': username,
    'events': events.map((e) => e.toJson()).toList(),
  };
}

class ExportProgressEvent {
  final int perceivedDifficulty;
  final String solvedAtUtc;

  ExportProgressEvent({
    required this.perceivedDifficulty,
    required this.solvedAtUtc,
  });

  Map<String, dynamic> toJson() => {
    'perceivedDifficulty': perceivedDifficulty,
    'solvedAtUtc': solvedAtUtc,
  };
}
