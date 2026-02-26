import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class ProblemListProblemDetailsScreen extends StatefulWidget {
  final int problemListId;
  final int probleId;

  const ProblemListProblemDetailsScreen({
    super.key,
    required this.problemListId,
    required this.probleId,
  });

  @override
  State<StatefulWidget> createState() =>
      _ProblemListProblemDetailsScreenState();
}

class _ProblemListProblemDetailsScreenState
    extends State<ProblemListProblemDetailsScreen> {
  final ProblemRepository _problemRepository = ProblemRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  late Future<(Problem?, Progress?)> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<(Problem?, Progress?)> _load() async {
    final problem = await _problemRepository.getById(widget.probleId);
    final progress = await _progressRepository.getByProblemAndList(
      widget.probleId,
      widget.problemListId,
    );
    return (problem, progress);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder<(Problem?, Progress?)>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final (problem, progress) = snapshot.data!;

        if (problem == null) {
          return const Center(child: Text('Problem not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: cs.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${problem.questionId}',
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _DifficultyChip(difficulty: problem.difficulty),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        problem.question,
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (progress != null) ...[
                Text(
                  'Progress',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.flag_outlined,
                          label: 'Status',
                          value: progress.status.label,
                          valueColor: _statusColor(progress.status, cs),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.psychology_outlined,
                          label: 'Perceived Difficulty',
                          value: progress.perceivedDifficulty.label,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.check_circle_outline,
                          label: 'Last Solved (UTC)',
                          value: _formatDate(progress.lastSolvedAtUtc),
                        ),
                        if (progress.nextReviewAtUtc != null) ...[
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.schedule_outlined,
                            label: 'Next Review (UTC)',
                            value: _formatDate(progress.nextReviewAtUtc!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: cs.outline),
                        const SizedBox(width: 12),
                        Text(
                          'No progress yet',
                          style: tt.bodyMedium?.copyWith(color: cs.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String utcString) {
    try {
      final dt = DateTime.parse(utcString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return utcString;
    }
  }

  Color _statusColor(Status status, ColorScheme cs) {
    switch (status) {
      case Status.mastered:
        return Colors.green;
      case Status.practicing:
        return cs.primary;
      case Status.frozen:
        return cs.outline;
    }
  }
}

class _DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      Difficulty.easy => ('Easy', Colors.green),
      Difficulty.medium => ('Medium', Colors.orange),
      Difficulty.hard => ('Hard', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.outline)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
