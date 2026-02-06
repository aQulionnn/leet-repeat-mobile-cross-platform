import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_repository.dart';

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

  String? _problemListProblemQuestion;
  Difficulty? _problemListProblemDifficulty;

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
            trailing: Text(snapshot.data![index].difficulty.name),
          ),
        );
      },
    );
  }

  Widget _addProblemListProblem() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Problem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _problemListProblemQuestion = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Question...',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Difficulty>(
                  value: _problemListProblemDifficulty,
                  items: Difficulty.values
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _problemListProblemDifficulty = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Difficulty',
                  ),
                ),
                const SizedBox(height: 12),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    if (_problemListProblemQuestion == null ||
                        _problemListProblemQuestion!.trim().isEmpty ||
                        _problemListProblemDifficulty == null) {
                      return;
                    }

                    final problemId = await _problemRepository.add(
                      Problem(
                        question: _problemListProblemQuestion!.trim(),
                        difficulty: _problemListProblemDifficulty!,
                      ),
                    );

                    await _problemListProblemRepository.add(
                      problemId,
                      widget.problemListId,
                    );

                    await _problemListProblemRepository.add(
                      problemId,
                      widget.problemListId,
                    );

                    _problemListProblemQuestion = null;
                    _problemListProblemDifficulty = null;

                    setState(() {});
                    
                    Navigator.pop(context);
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
