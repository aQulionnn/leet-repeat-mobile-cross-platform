import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/clients/leetcode_client.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/status.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';

class ProblemListProblemsScreen extends StatefulWidget {
  final int problemListId;

  const ProblemListProblemsScreen({super.key, required this.problemListId});

  @override
  State<StatefulWidget> createState() => _ProblemListProblemsScreenState();
}

class _ProblemListProblemsScreenState extends State<ProblemListProblemsScreen> {
  final ProblemListProblemRepository _problemListProblemRepository =
      ProblemListProblemRepository();
  final ProblemRepository _problemRepository = ProblemRepository();
  final ProgressRepository _progressRepository = ProgressRepository();

  final LeetCodeClient _leetCodeClient = LeetCodeClient();

  int? _questionId;
  PerceivedDifficulty? _perceivedDifficulty;
  int? _problemId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: _problemListProblems()),
        Positioned(bottom: 24, right: 24, child: _addProblemListProblem()),
      ],
    );
  }

  Widget _problemListProblems() {
    return FutureBuilder(
      future: _problemListProblemRepository.getByList(widget.problemListId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No problems yet!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(snapshot.data![index].question),
            trailing: Text(
              snapshot.data![index].difficulty.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _difficultyColor(
                  context,
                  snapshot.data![index].difficulty,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _difficultyColor(BuildContext context, Difficulty d) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    switch (d) {
      case Difficulty.easy:
        return isLightMode ? Colors.green : Colors.greenAccent;
      case Difficulty.medium:
        return isLightMode ? Colors.yellow : Colors.yellowAccent;
      case Difficulty.hard:
        return isLightMode ? Colors.red : Colors.redAccent;
    }
  }

  Widget _addProblemListProblem() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Add Problem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _questionId = int.tryParse(value);
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Question Id',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PerceivedDifficulty>(
                  initialValue: _perceivedDifficulty,
                  items: PerceivedDifficulty.values
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.label)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _perceivedDifficulty = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Perceived Difficulty',
                  ),
                ),
                const SizedBox(height: 12),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    final questionId = _questionId;
                    final perceivedDifficulty = _perceivedDifficulty;

                    if (questionId == null ||
                        questionId <= 0 ||
                        perceivedDifficulty == null) {
                      return;
                    }

                    final nav = Navigator.of(dialogContext);

                    final problem = await _problemRepository.getByQuestionId(
                      questionId,
                    );

                    if (problem == null) {
                      final response = await _leetCodeClient
                          .getProblemByQuestionId(questionId);
                      if (response == null) return;

                      _problemId = await _problemRepository.add(
                        Problem(
                          questionId: questionId,
                          question: response.question,
                          difficulty: response.difficulty,
                        ),
                      );
                    }

                    final problemId = _problemId;
                    if (problemId == null) return;

                    await _problemListProblemRepository.add(
                      problemId,
                      widget.problemListId,
                    );

                    final now = DateTime.now().toUtc();
                    final nextReviewDate = _nextReview(
                      perceivedDifficulty,
                      now,
                    );

                    final status =
                        perceivedDifficulty == PerceivedDifficulty.veryEasy
                        ? Status.mastered
                        : Status.practicing;

                    await _progressRepository.upsert(
                      Progress(
                        perceivedDifficulty: perceivedDifficulty,
                        lastSolvedAt: now.toIso8601String(),
                        nextReviewAt: nextReviewDate?.toIso8601String(),
                        status: status,
                        problemId: problemId,
                        problemListId: widget.problemListId,
                      ),
                    );

                    _questionId = null;
                    _perceivedDifficulty = null;
                    _problemId = null;

                    if (!mounted) return;
                    nav.pop();

                    setState(() {});
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
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
