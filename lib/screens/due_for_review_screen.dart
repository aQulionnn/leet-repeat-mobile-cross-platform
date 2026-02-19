import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/dtos/due_for_review_dto.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
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
    ).add(const Duration(hours: 24)).toIso8601String();
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
          return const Center(child: Text('Nothing due yet!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            final date = DateTime.parse(item.progress.nextReviewAtUtc!);
            final formatted = DateFormat('dd/MM/yyyy').format(date.toUtc());

            return ListTile(
              title: Text(item.problem.question),
              subtitle: Text(
                '${item.problemList.name} \n$formatted \n${item.progress.perceivedDifficulty.label}',
              ),
              trailing: PopupMenuButton<_DueAction>(
                onSelected: (a) async {
                  if (a == _DueAction.solve) {
                    await _solve(item);
                    return;
                  }
                  if (a == _DueAction.freeze) {
                    await _freeze(item);
                    return;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _DueAction.solve, child: Text('Solve')),
                  PopupMenuItem(
                    value: _DueAction.freeze,
                    child: Text('Freeze'),
                  ),
                ],
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

enum _DueAction { solve, freeze }

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
