import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';

class ProgressEvent {
  int? id;
  final int progressId;
  final PerceivedDifficulty perceivedDifficulty;
  final String solvedAtUtc;

  ProgressEvent({
    this.id,
    required this.progressId,
    required this.perceivedDifficulty,
    required this.solvedAtUtc,
  });

  factory ProgressEvent.fromJson(Map<String, dynamic> json) => ProgressEvent(
    id: json['id'],
    progressId: json['progress_id'],
    perceivedDifficulty: PerceivedDifficulty.values[json['perceived_difficulty']],
    solvedAtUtc: json['solved_at_utc'],
  );
}