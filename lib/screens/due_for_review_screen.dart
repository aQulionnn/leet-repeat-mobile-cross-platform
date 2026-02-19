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

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: _dueForReviewList())]);
  }

  Widget _dueForReviewList() {
    final nowUtc = DateTime.now().toUtc();
    final nowIsoUtc = DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
    ).add(const Duration(hours: 24)).toIso8601String();

    return FutureBuilder<List<DueForReviewDto>>(
      future: _progressRepository.getDueForReview(nowIsoUtc),
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
              subtitle: Text('${item.problemList.name} \n$formatted \n${item.progress.perceivedDifficulty.label}')
            );
          },
        );
      },
    );
  }
}
