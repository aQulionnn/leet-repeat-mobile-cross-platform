import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/language_stats_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/get_problem_by_question_id_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/get_user_public_profile_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/question_progress_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/skill_stats_response.dart';

class LeetCodeClient {
  late final HttpLink _link;
  late final GraphQLClient _client;

  LeetCodeClient() {
    _link = HttpLink(
      'https://leetcode.com/graphql',
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Referer': 'https://leetcode.com',
        'Origin': 'https://leetcode.com',
      },
    );
    _client = GraphQLClient(link: _link, cache: GraphQLCache());
  }

  Future<GetProblemByQuestionIdResponse?> getProblemByQuestionId(int id) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query ($skip: Int!) {
            questionList(categorySlug: "", limit: 1, skip: $skip, filters: {}) {
              questions: data {
                questionFrontendId
                title
                difficulty
              }
            }
          }
        '''),
        variables: {"skip": id - 1},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) {
      throw response.exception!;
    }

    final questions =
        response.data?['questionList']['questions'] as List<dynamic>;
    if (questions.isEmpty) return null;

    return GetProblemByQuestionIdResponse.fromJson(
      questions.first as Map<String, dynamic>,
    );
  }

  Future<GetUserPublicProfileResponse?> getUserPublicProfile(
    String username,
  ) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query ($username: String!) {
            matchedUser(username: $username) {
              username
              githubUrl
              profile {
                ranking
                userAvatar
              }
            }
          }
        '''),
        variables: {'username': username},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) {
      throw response.exception!;
    }

    final matchedUser = response.data?['matchedUser'];
    if (matchedUser == null) return null;

    return GetUserPublicProfileResponse.fromJson(
      matchedUser as Map<String, dynamic>,
    );
  }

  Future<List<LanguageStats>> getLanguageStats(String username) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query ($username: String!) {
            matchedUser(username: $username) {
              languageProblemCount {
                languageName
                problemsSolved
              }
            }
          }
        '''),
        variables: {'username': username},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) {
      throw response.exception!;
    }

    final matchedUser = response.data?['matchedUser'];
    if (matchedUser == null) return [];

    final list = matchedUser['languageProblemCount'] as List<dynamic>;
    return list
        .map((e) => LanguageStats.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SkillStats?> getSkillStats(String username) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query ($username: String!) {
            matchedUser(username: $username) {
              tagProblemCounts {
                advanced {
                  tagName
                  tagSlug
                  problemsSolved
                }
                intermediate {
                  tagName
                  tagSlug
                  problemsSolved
                }
                fundamental {
                  tagName
                  tagSlug
                  problemsSolved
                }
              }
            }
          }
        '''),
        variables: {'username': username},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) throw response.exception!;

    final matchedUser = response.data?['matchedUser'];
    if (matchedUser == null) return null;

    return SkillStats.fromJson(
      matchedUser['tagProblemCounts'] as Map<String, dynamic>,
    );
  }

  Future<QuestionProgress?> getQuestionProgress(String username) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query ($userSlug: String!) {
            userProfileUserQuestionProgressV2(userSlug: $userSlug) {
              numAcceptedQuestions {
                count
                difficulty
              }
              numFailedQuestions {
                count
                difficulty
              }
              numUntouchedQuestions {
                count
                difficulty
              }
              userSessionBeatsPercentage {
                difficulty
                percentage
              }
              totalQuestionBeatsPercentage
            }
          }
        '''),
        variables: {'userSlug': username},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) throw response.exception!;

    final data = response.data?['userProfileUserQuestionProgressV2'];
    if (data == null) return null;

    return QuestionProgress.fromJson(data as Map<String, dynamic>);
  }
}
