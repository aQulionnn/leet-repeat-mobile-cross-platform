class LanguageStats {
  final String languageName;
  final int problemsSolved;

  LanguageStats({required this.languageName, required this.problemsSolved});

  factory LanguageStats.fromJson(Map<String, dynamic> json) => LanguageStats(
    languageName: json['languageName'],
    problemsSolved: json['problemsSolved'],
  );
}
