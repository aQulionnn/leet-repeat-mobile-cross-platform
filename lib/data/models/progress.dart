class Progress {
  int? id;
  PerceivedDifficulty perceivedDifficulty;
  String lastSolvedAt;
  String nextReviewAt;
  int problemId;
  int problemListId;

  Progress({
    this.id,
    required this.perceivedDifficulty,
    required this.lastSolvedAt,
    required this.nextReviewAt,
    required this.problemId,
    required this.problemListId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'perceived_difficulty': perceivedDifficulty.index,
    'last_solved_at': lastSolvedAt,
    'next_review_at': nextReviewAt,
    'problem_id': problemId,
    'problem_list_id': problemListId,
  };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    id: json['id'],
    perceivedDifficulty:
        PerceivedDifficulty.values[json['perceived_difficulty']],
    lastSolvedAt: json['last_solved_at'],
    nextReviewAt: json['next_review_at'],
    problemId: json['problem_id'],
    problemListId: json['problem_list_id'],
  );
}

enum PerceivedDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
  extremelyHard,
}