// skill_stats_response.dart
class SkillTag {
  final String tagName;
  final String tagSlug;
  final int problemsSolved;

  SkillTag({
    required this.tagName,
    required this.tagSlug,
    required this.problemsSolved,
  });

  factory SkillTag.fromJson(Map<String, dynamic> json) => SkillTag(
    tagName: json['tagName'],
    tagSlug: json['tagSlug'],
    problemsSolved: json['problemsSolved'],
  );
}

class SkillStats {
  final List<SkillTag> advanced;
  final List<SkillTag> intermediate;
  final List<SkillTag> fundamental;

  SkillStats({
    required this.advanced,
    required this.intermediate,
    required this.fundamental,
  });

  factory SkillStats.fromJson(Map<String, dynamic> json) => SkillStats(
    advanced: (json['advanced'] as List)
        .map((e) => SkillTag.fromJson(e))
        .toList(),
    intermediate: (json['intermediate'] as List)
        .map((e) => SkillTag.fromJson(e))
        .toList(),
    fundamental: (json['fundamental'] as List)
        .map((e) => SkillTag.fromJson(e))
        .toList(),
  );
}
