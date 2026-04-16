import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ProblemListRepository _problemListRepository = ProblemListRepository();
  final ProblemListProblemRepository _problemListProblemRepository =
      ProblemListProblemRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _overallProgressSection(),
          const SizedBox(height: 24),
          _difficultyDistributionSection(),
          const SizedBox(height: 24),
          _perceivedDifficultyDistributionSection(),
          const SizedBox(height: 24),
          _listStatisticsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _overallProgressSection() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _getOverallProgress(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Card(
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _statRow('Practicing', data['practicing']!.toInt(), cs.primary),
                const SizedBox(height: 12),
                _statRow('Mastered', data['mastered']!.toInt(), Colors.green),
                const SizedBox(height: 12),
                _statRow('Frozen', data['frozen']!.toInt(), cs.outline),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _difficultyDistributionSection() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _getDifficultyDistribution(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final total = data.values.fold<int>(0, (a, b) => a + b);

        return Card(
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Difficulty Distribution',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...Difficulty.values.map((difficulty) {
                  final label = difficulty.name;
                  final count = data[difficulty] ?? 0;
                  final percentage = total > 0
                      ? (count / total * 100).toStringAsFixed(1)
                      : '0';
                  final color = _difficultyColor(difficulty);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label.capitalize()),
                            Text('$count ($percentage%)'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? count / total : 0,
                            minHeight: 8,
                            backgroundColor: color.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _perceivedDifficultyDistributionSection() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _getPerceivedDifficultyDistribution(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final total = data.values.fold<int>(0, (a, b) => a + b);

        return Card(
          elevation: 0,
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perceived Difficulty Distribution',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...PerceivedDifficulty.values.map((perceivedDifficulty) {
                  final label = perceivedDifficulty.label;
                  final count = data[perceivedDifficulty] ?? 0;
                  final percentage = total > 0
                      ? (count / total * 100).toStringAsFixed(1)
                      : '0';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label),
                            Text('$count ($percentage%)'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? count / total : 0,
                            minHeight: 8,
                            backgroundColor: cs.secondary.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF6200EE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listStatisticsSection() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _getListStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final lists = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Per-List Statistics',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...lists.map((listStat) {
              return Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listStat['name'],
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Total', style: tt.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                listStat['total'].toString(),
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Mastered %', style: tt.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                '${listStat['masteredPercent']}%',
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Avg Difficulty', style: tt.labelSmall),
                              const SizedBox(height: 4),
                              Text(
                                listStat['avgPerceivedDifficulty'],
                                style: tt.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _difficultyColor(Difficulty difficulty) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    switch (difficulty) {
      case Difficulty.easy:
        return isLightMode ? Colors.green : Colors.greenAccent;
      case Difficulty.medium:
        return isLightMode ? Colors.orange : Colors.orangeAccent;
      case Difficulty.hard:
        return isLightMode ? Colors.red : Colors.redAccent;
    }
  }

  Future<Map<String, int>> _getOverallProgress() async {
    final problemLists = await _problemListRepository.getAll();
    int practicing = 0;
    int mastered = 0;
    int frozen = 0;

    for (final list in problemLists) {
      final problems = await _problemListProblemRepository.getByList(list.id!);
      for (final problem in problems) {
        final progress = await _progressRepository.getByProblemAndList(
          problem.id!,
          list.id!,
        );

        if (progress == null) continue;

        switch (progress.status) {
          case Status.practicing:
            practicing++;
          case Status.mastered:
            mastered++;
          case Status.frozen:
            frozen++;
        }
      }
    }

    return {'practicing': practicing, 'mastered': mastered, 'frozen': frozen};
  }

  Future<Map<Difficulty, int>> _getDifficultyDistribution() async {
    final problemLists = await _problemListRepository.getAll();
    final distribution = {
      Difficulty.easy: 0,
      Difficulty.medium: 0,
      Difficulty.hard: 0,
    };

    for (final list in problemLists) {
      final problems = await _problemListProblemRepository.getByList(list.id!);
      for (final problem in problems) {
        distribution[problem.difficulty] =
            (distribution[problem.difficulty] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Future<Map<PerceivedDifficulty, int>>
  _getPerceivedDifficultyDistribution() async {
    final problemLists = await _problemListRepository.getAll();
    final distribution = <PerceivedDifficulty, int>{};

    for (final list in problemLists) {
      final problems = await _problemListProblemRepository.getByList(list.id!);
      for (final problem in problems) {
        final progress = await _progressRepository.getByProblemAndList(
          problem.id!,
          list.id!,
        );

        if (progress == null) continue;

        distribution[progress.perceivedDifficulty] =
            (distribution[progress.perceivedDifficulty] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Future<List<Map<String, dynamic>>> _getListStatistics() async {
    final problemLists = await _problemListRepository.getAll();
    final stats = <Map<String, dynamic>>[];

    for (final list in problemLists) {
      final problems = await _problemListProblemRepository.getByList(list.id!);
      int total = problems.length;
      int mastered = 0;
      final perceivedDifficultySum = <int>[];

      for (final problem in problems) {
        final progress = await _progressRepository.getByProblemAndList(
          problem.id!,
          list.id!,
        );

        if (progress == null) continue;

        if (progress.status == Status.mastered) {
          mastered++;
        }

        perceivedDifficultySum.add(progress.perceivedDifficulty.index);
      }

      final masteredPercent = total > 0
          ? ((mastered / total) * 100).toStringAsFixed(0)
          : '0';
      final avgPerceivedIndex = perceivedDifficultySum.isEmpty
          ? 0
          : (perceivedDifficultySum.reduce((a, b) => a + b) /
                    perceivedDifficultySum.length)
                .round();
      final avgPerceivedDifficulty =
          PerceivedDifficulty.values[avgPerceivedIndex].label;

      stats.add({
        'name': list.name,
        'total': total,
        'masteredPercent': masteredPercent,
        'avgPerceivedDifficulty': avgPerceivedDifficulty,
      });
    }

    return stats;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
