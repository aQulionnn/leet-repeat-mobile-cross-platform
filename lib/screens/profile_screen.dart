import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leet_repeat_mobile_cross_platform/data/clients/leetcode_client.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/get_user_public_profile_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/language_stats_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/question_progress_response.dart';
import 'package:leet_repeat_mobile_cross_platform/utils/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = LeetCodeClient();

  late Future<
    (GetUserPublicProfileResponse?, QuestionProgress?, List<LanguageStats>)
  >
  _data;

  @override
  void initState() {
    super.initState();
    final username = context.read<UserProvider>().username ?? '';
    _data = _load(username);
  }

  Future<
    (GetUserPublicProfileResponse?, QuestionProgress?, List<LanguageStats>)
  >
  _load(String username) async {
    final results = await Future.wait([
      _client.getUserPublicProfile(username),
      _client.getQuestionProgress(username),
      _client.getLanguageStats(username),
    ]);
    return (
      results[0] as GetUserPublicProfileResponse?,
      results[1] as QuestionProgress?,
      results[2] as List<LanguageStats>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FutureBuilder(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final (profile, progress, languages) = snapshot.data!;
        if (profile == null) {
          return const Center(child: Text('Profile not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile card
              Card(
                elevation: 0,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: profile.userAvatar != null
                            ? NetworkImage(profile.userAvatar!)
                            : null,
                        backgroundColor: cs.primaryContainer,
                        child: profile.userAvatar == null
                            ? Icon(
                                Icons.person_outline,
                                color: cs.onPrimaryContainer,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.username,
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 16,
                                  color: cs.outline,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rank #${profile.ranking}',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.outline,
                                  ),
                                ),
                              ],
                            ),
                            if (profile.githubUrl != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.link, size: 16, color: cs.outline),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      profile.githubUrl!.replaceFirst(
                                        'https://github.com/',
                                        '',
                                      ),
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (progress != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Problems Solved',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DifficultyCount(
                          label: 'Easy',
                          count: progress.numAcceptedQuestions
                              .firstWhere(
                                (e) => e.difficulty == 'EASY',
                                orElse: () =>
                                    QuestionCount(count: 0, difficulty: 'EASY'),
                              )
                              .count,
                          color: Colors.green,
                        ),
                        _DifficultyCount(
                          label: 'Medium',
                          count: progress.numAcceptedQuestions
                              .firstWhere(
                                (e) => e.difficulty == 'MEDIUM',
                                orElse: () => QuestionCount(
                                  count: 0,
                                  difficulty: 'MEDIUM',
                                ),
                              )
                              .count,
                          color: Colors.orange,
                        ),
                        _DifficultyCount(
                          label: 'Hard',
                          count: progress.numAcceptedQuestions
                              .firstWhere(
                                (e) => e.difficulty == 'HARD',
                                orElse: () =>
                                    QuestionCount(count: 0, difficulty: 'HARD'),
                              )
                              .count,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.percent,
                          label: 'Total beats',
                          value:
                              '${progress.totalQuestionBeatsPercentage.toStringAsFixed(1)}%',
                        ),
                        ...progress.userSessionBeatsPercentage.map((e) {
                          return Column(
                            children: [
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.bar_chart,
                                label:
                                    '${e.difficulty[0]}${e.difficulty.substring(1).toLowerCase()} beats',
                                value: '${e.percentage.toStringAsFixed(1)}%',
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              if (languages.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Languages',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: languages.asMap().entries.map((entry) {
                        final isLast = entry.key == languages.length - 1;
                        final lang = entry.value;
                        return Column(
                          children: [
                            _InfoRow(
                              icon: Icons.code,
                              label: lang.languageName,
                              value: '${lang.problemsSolved} solved',
                            ),
                            if (!isLast) const Divider(height: 24),
                          ],
                        );
                      }).toList(),
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
}

class _DifficultyCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _DifficultyCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          '$count',
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: tt.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.outline),
        const SizedBox(width: 12),
        Text(label, style: tt.bodyMedium?.copyWith(color: cs.outline)),
        const Spacer(),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
