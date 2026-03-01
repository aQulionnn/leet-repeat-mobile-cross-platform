import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/clients/leet_repeat_client.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leet_repeat/export_request.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/problem_list_problem.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_list_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/problem_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _progressRepository = ProgressRepository();
  final _problemRepository = ProblemRepository();
  final _problemListRepository = ProblemListRepository();
  final _problemListProblemRepository = ProblemListProblemRepository();
  final _client = LeetRepeatClient();

  bool _exportLoading = false;
  bool _importLoading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cloud Sync',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.upload_outlined, color: cs.primary),
                  title: const Text('Export to cloud'),
                  subtitle: const Text('Save your progress to the server'),
                  trailing: _exportLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _exportLoading ? null : _export,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.download_outlined, color: cs.primary),
                  title: const Text('Import from cloud'),
                  subtitle: const Text('Restore your progress from the server'),
                  trailing: _importLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _importLoading ? null : _import,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _exportLoading = true);

    try {
      final all = await _progressRepository.getAllForExport();

      final request = all
          .map(
            (dto) => ExportRequest(
              perceivedDifficulty: dto.progress.perceivedDifficulty.index,
              status: dto.progress.status.index,
              lastSolvedAtUtc: dto.progress.lastSolvedAtUtc,
              nextReviewAtUtc: dto.progress.nextReviewAtUtc,
              problemQuestionId: dto.problem.questionId,
              problemQuestion: dto.problem.question,
              problemDifficulty: dto.problem.difficulty.index,
              problemListName: dto.problemList.name,
            ),
          )
          .toList();

      final response = await _client.export(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${response.count} records')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      setState(() => _exportLoading = false);
    }
  }

  Future<void> _import() async {
    setState(() => _importLoading = true);

    try {
      final items = await _client.import();

      for (final item in items) {
        int problemListId = await _problemListRepository.getOrCreateByName(
          item.problemListName,
        );

        int problemId = await _problemRepository.getOrCreateByQuestionId(
          questionId: item.problemQuestionId,
          question: item.problemQuestion,
          difficulty: item.problemDifficulty,
        );

        await _problemListProblemRepository.add(
          ProblemListProblem(
            problemId: problemId,
            problemListId: problemListId,
          ),
        );

        await _progressRepository.upsert(
          Progress(
            perceivedDifficulty: item.perceivedDifficulty,
            lastSolvedAtUtc: item.lastSolvedAtUtc ?? '',
            nextReviewAtUtc: item.nextReviewAtUtc,
            status: item.status,
            problemId: problemId,
            problemListId: problemListId,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported ${items.length} records')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      setState(() => _importLoading = false);
    }
  }
}
