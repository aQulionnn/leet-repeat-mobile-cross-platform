import 'package:flutter/material.dart';
import 'package:leet_repeat_mobile_cross_platform/data/enums/perceived_difficulty.dart';
import 'package:leet_repeat_mobile_cross_platform/data/repositories/progress_repository.dart';
import 'package:leet_repeat_mobile_cross_platform/data/models/progress.dart';

class DueForReviewScreen extends StatefulWidget {
  const DueForReviewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DueForReviewScreenState();
}

class _DueForReviewScreenState extends State<DueForReviewScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Center(child: _dueList())]);
  }

  Widget _dueList() {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    return FutureBuilder<List<Progress>>(
      future: _progressRepository.getDueForReview(nowIso),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(snapshot.data![index].problemId.toString()),
            trailing: Text(
              snapshot.data![index].perceivedDifficulty.label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}
