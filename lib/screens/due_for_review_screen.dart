import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/dtos/due_for_review_dto.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';
import 'package:intl/intl.dart';

class DueForReviewScreen extends StatefulWidget {
  const DueForReviewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DueForReviewScreenState();
}

class _DueForReviewScreenState extends State<DueForReviewScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  late Future<List<DueForReviewDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _progressRepository.getDueForReview(_dueBoundaryIsoUtc());
  }

  String _dueBoundaryIsoUtc() {
    final nowUtc = DateTime.now().toUtc();
    return DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
    ).add(const Duration(hours: 240)).toIso8601String();
  }

  void _refresh() {
    setState(() {
      _future = _progressRepository.getDueForReview(_dueBoundaryIsoUtc());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: _dueForReviewList())]);
  }

  Widget _dueForReviewList() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder<List<DueForReviewDto>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all_outlined, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                Text(
                  'All caught up!',
                  style: tt.bodyLarge?.copyWith(color: cs.outline),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nothing due for review',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(10, 24, 10, 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final item = items[index];
            final date = DateTime.parse(item.progress.nextReviewAtUtc!);
            final formatted = DateFormat('dd MMM yyyy').format(date.toLocal());
            final isOverdue = date.isBefore(DateTime.now());
            final isFrozen = item.progress.status == Status.frozen;

            return Dismissible(
              key: ValueKey(item.progress.id),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await _solve(item);
                } else {
                  await _freeze(item);
                }
                return false;
              },
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Solve',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Freeze',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.ac_unit, color: Colors.white),
                  ],
                ),
              ),
              child: Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.problem.question,
                              style: tt.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.problemList.name,
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFrozen
                                        ? cs.outline.withValues(alpha: 0.12)
                                        : isOverdue
                                        ? cs.errorContainer
                                        : cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isFrozen
                                            ? Icons.ac_unit
                                            : Icons.schedule_outlined,
                                        size: 11,
                                        color: isFrozen
                                            ? cs.outline
                                            : isOverdue
                                            ? cs.onErrorContainer
                                            : cs.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatted,
                                        style: tt.labelSmall?.copyWith(
                                          color: isFrozen
                                              ? cs.outline
                                              : isOverdue
                                              ? cs.onErrorContainer
                                              : cs.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.progress.perceivedDifficulty.label,
                              style: tt.labelSmall?.copyWith(color: cs.outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _solve(DueForReviewDto item) async {
    final selected = await showDialog<PerceivedDifficulty>(
      context: context,
      builder: (ctx) {
        PerceivedDifficulty value = item.progress.perceivedDifficulty;
        return AlertDialog(
          title: const Text('How hard was it?'),
          content: StatefulBuilder(
            builder: (ctx, setLocal) {
              return DropdownButton<PerceivedDifficulty>(
                value: value,
                isExpanded: true,
                items: PerceivedDifficulty.values
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text(d.label)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() => value = v);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, value),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    final nowUtc = DateTime.now().toUtc();
    final next = _nextReview(selected, nowUtc);

    item.progress.perceivedDifficulty = selected;
    item.progress.nextReviewAtUtc = next?.toIso8601String();

    await _progressRepository.upsert(item.progress);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next == null
              ? 'Mastered: no more reviews'
              : 'Solved: next review ${DateFormat('dd/MM/yyyy').format(next.toUtc())}',
        ),
      ),
    );
    _refresh();
  }

  Future<void> _freeze(DueForReviewDto item) async {
    final selectedDays = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int days = 7;
        return AlertDialog(
          title: const Text('Freeze for'),
          content: StatefulBuilder(
            builder: (ctx, setLocal) {
              final options = [1, 3, 7, 14, 30, 60, 90];
              return DropdownButton<int>(
                value: days,
                isExpanded: true,
                items: options
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text('$d days')),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() => days = v);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, days),
              child: const Text('Freeze'),
            ),
          ],
        );
      },
    );

    if (selectedDays == null) return;

    final nowUtc = DateTime.now().toUtc();
    final frozenUntil = nowUtc.add(Duration(days: selectedDays));

    item.progress.nextReviewAtUtc = frozenUntil.toIso8601String();

    await _progressRepository.upsert(item.progress);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Frozen until ${DateFormat('dd/MM/yyyy').format(frozenUntil.toUtc())}',
        ),
      ),
    );
    _refresh();
  }
}

DateTime? _nextReview(PerceivedDifficulty d, DateTime dateTime) {
  switch (d) {
    case PerceivedDifficulty.veryEasy:
      return null;
    case PerceivedDifficulty.easy:
      return _addMonths(dateTime, 1);
    case PerceivedDifficulty.medium:
      return dateTime.add(const Duration(days: 14));
    case PerceivedDifficulty.hard:
      return dateTime.add(const Duration(days: 7));
    case PerceivedDifficulty.veryHard:
      return dateTime.add(const Duration(days: 3));
    case PerceivedDifficulty.extremelyHard:
      return dateTime.add(const Duration(days: 1));
  }
}

DateTime _addMonths(DateTime date, int months) {
  return DateTime.utc(
    date.year,
    date.month + months,
    date.day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}
