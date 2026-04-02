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
  };
}