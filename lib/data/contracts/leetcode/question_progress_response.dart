class QuestionCount {
  final int count;
  final String difficulty;

  QuestionCount({required this.count, required this.difficulty});

  factory QuestionCount.fromJson(Map<String, dynamic> json) =>
      QuestionCount(count: json['count'], difficulty: json['difficulty']);
}

class SessionBeats {
  final String difficulty;
  final double percentage;

  SessionBeats({required this.difficulty, required this.percentage});

  factory SessionBeats.fromJson(Map<String, dynamic> json) => SessionBeats(
    difficulty: json['difficulty'],
    percentage: (json['percentage'] as num).toDouble(),
  );
}

class QuestionProgress {
  final List<QuestionCount> numAcceptedQuestions;
  final List<QuestionCount> numFailedQuestions;
  final List<QuestionCount> numUntouchedQuestions;
  final List<SessionBeats> userSessionBeatsPercentage;
  final double totalQuestionBeatsPercentage;

  QuestionProgress({
    required this.numAcceptedQuestions,
    required this.numFailedQuestions,
    required this.numUntouchedQuestions,
    required this.userSessionBeatsPercentage,
    required this.totalQuestionBeatsPercentage,
  });

  factory QuestionProgress.fromJson(Map<String, dynamic> json) =>
      QuestionProgress(
        numAcceptedQuestions: (json['numAcceptedQuestions'] as List)
            .map((e) => QuestionCount.fromJson(e))
            .toList(),
        numFailedQuestions: (json['numFailedQuestions'] as List)
            .map((e) => QuestionCount.fromJson(e))
            .toList(),
        numUntouchedQuestions: (json['numUntouchedQuestions'] as List)
            .map((e) => QuestionCount.fromJson(e))
            .toList(),
        userSessionBeatsPercentage: (json['userSessionBeatsPercentage'] as List)
            .map((e) => SessionBeats.fromJson(e))
            .toList(),
        totalQuestionBeatsPercentage:
            (json['totalQuestionBeatsPercentage'] as num).toDouble(),
      );
}
