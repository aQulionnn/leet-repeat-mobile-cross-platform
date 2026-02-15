enum PerceivedDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
  extremelyHard,
}

extension PerceivedDifficultyX on PerceivedDifficulty {
  String get label {
    switch (this) {
      case PerceivedDifficulty.veryEasy:
        return 'Very Easy';
      case PerceivedDifficulty.easy:
        return 'Easy';
      case PerceivedDifficulty.medium:
        return 'Meduim';
      case PerceivedDifficulty.hard:
        return 'Hard';
      case PerceivedDifficulty.veryHard:
        return 'Very Hard';
      case PerceivedDifficulty.extremelyHard:
        return 'Extremely Hard';
    }
  }
}
