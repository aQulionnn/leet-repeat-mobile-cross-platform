import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/clients/leetcode_client.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/question_detail_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/recent_ac_submission.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list_problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/user_provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';

class ImportFromLeetCodeScreen extends StatefulWidget {
  final int problemListId;

  const ImportFromLeetCodeScreen({super.key, required this.problemListId});

  @override
  State<ImportFromLeetCodeScreen> createState() =>
      _ImportFromLeetCodeScreenState();
}

class _ImportFromLeetCodeScreenState extends State<ImportFromLeetCodeScreen> {
  final _leetCodeClient = LeetCodeClient();
  final _problemRepository = ProblemRepository();
  final _progressRepository = ProgressRepository();
  final _problemListProblemRepository = ProblemListProblemRepository();

  List<_SubmissionWithDetail> _submissions = [];
  final Set<int> _selectedIndices = {};
  PerceivedDifficulty _perceivedDifficulty = PerceivedDifficulty.medium;

  bool _loading = true;
  bool _adding = false;
  String? _error;
  int _loaded = 0;
  int _total = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final username = context.read<UserProvider>().username ?? '';
    try {
      final submissions = await _leetCodeClient.getRecentAcSubmissions(
        username,
      );

      final seen = <String>{};
      final unique = submissions.where((s) => seen.add(s.titleSlug)).toList();

      setState(() => _total = unique.length);

      final results = <_SubmissionWithDetail>[];
      for (final s in unique) {
        final detail = await _leetCodeClient.getQuestionDetail(s.titleSlug);
        if (detail != null) {
          results.add(_SubmissionWithDetail(submission: s, detail: detail));
        }
        setState(() => _loaded++);
      }

      setState(() {
        _submissions = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addSelected() async {
    if (_selectedIndices.isEmpty) return;
    setState(() => _adding = true);

    try {
      final addedIndices = <int>{};

      for (final i in _selectedIndices) {
        final item = _submissions[i];

        final existingProblem = await _problemRepository.getByQuestionId(
          item.detail.questionId,
        );

        int problemId;
        if (existingProblem != null) {
          problemId = existingProblem.id!;
        } else {
          problemId = await _problemRepository.add(
            Problem(
              questionId: item.detail.questionId,
              question: '${item.detail.questionId}. ${item.detail.title}',
              difficulty: item.detail.difficulty,
            ),
          );
        }

        await _problemListProblemRepository.add(
          ProblemListProblem(
            problemId: problemId,
            problemListId: widget.problemListId,
          ),
        );

        final nowUtc = DateTime.now().toUtc();
        final status = _perceivedDifficulty == PerceivedDifficulty.veryEasy
            ? Status.mastered
            : Status.practicing;

        await _progressRepository.upsert(
          Progress(
            perceivedDifficulty: _perceivedDifficulty,
            lastSolvedAtUtc: nowUtc.toIso8601String(),
            nextReviewAtUtc: _nextReview(
              _perceivedDifficulty,
              nowUtc,
            )?.toIso8601String(),
            status: status,
            problemId: problemId,
            problemListId: widget.problemListId,
          ),
        );

        addedIndices.add(i);
      }

      final addedSorted = addedIndices.toList()..sort((a, b) => b.compareTo(a));
      for (final i in addedSorted) {
        _submissions.removeAt(i);
      }

      setState(() {
        _selectedIndices.clear();
      });

      if (!mounted) return;

      if (_submissions.isEmpty) {
        context.pop();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${addedIndices.length} problems')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Import from LeetCode'),
        centerTitle: true,
        actions: [
          if (_selectedIndices.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                if (_selectedIndices.length == _submissions.length) {
                  _selectedIndices.clear();
                } else {
                  _selectedIndices.addAll(
                    List.generate(_submissions.length, (i) => i),
                  );
                }
              }),
              child: Text(
                _selectedIndices.length == _submissions.length
                    ? 'Deselect all'
                    : 'Select all',
              ),
            ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading $_loaded / $_total',
                    style: tt.bodyMedium?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _submissions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: cs.outline),
                  const SizedBox(height: 12),
                  Text(
                    'No submissions found',
                    style: tt.bodyLarge?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search problems...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final entry = _filtered[index];
                      final realIndex = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndices.contains(realIndex);
                      final (
                        diffLabel,
                        diffColor,
                      ) = switch (item.detail.difficulty) {
                        Difficulty.easy => ('Easy', Colors.green),
                        Difficulty.medium => ('Medium', Colors.orange),
                        Difficulty.hard => ('Hard', Colors.red),
                      };

                      return ListTile(
                        onTap: () => setState(() {
                          isSelected
                              ? _selectedIndices.remove(realIndex)
                              : _selectedIndices.add(realIndex);
                        }),
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (_) => setState(() {
                            isSelected
                                ? _selectedIndices.remove(realIndex)
                                : _selectedIndices.add(realIndex);
                          }),
                        ),
                        title: Text(
                          '${item.detail.questionId}. ${item.detail.title}',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            diffLabel,
                            style: tt.labelSmall?.copyWith(
                              color: diffColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PerceivedDifficulty>(
                          initialValue: _perceivedDifficulty,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Perceived Difficulty',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: PerceivedDifficulty.values
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.label),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _perceivedDifficulty = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _adding || _selectedIndices.isEmpty
                            ? null
                            : _addSelected,
                        child: _adding
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Add ${_selectedIndices.length}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<MapEntry<int, _SubmissionWithDetail>> get _filtered {
    if (_searchQuery.isEmpty) {
      return _submissions.asMap().entries.toList();
    }
    return _submissions
        .asMap()
        .entries
        .where(
          (e) => e.value.detail.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }
}

class _SubmissionWithDetail {
  final RecentAcSubmission submission;
  final QuestionDetailResponse detail;

  _SubmissionWithDetail({required this.submission, required this.detail});
}

DateTime? _nextReview(PerceivedDifficulty d, DateTime dateTime) {
  switch (d) {
    case PerceivedDifficulty.veryEasy:
      return null;
    case PerceivedDifficulty.easy:
      return DateTime.utc(dateTime.year, dateTime.month + 1, dateTime.day);
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
