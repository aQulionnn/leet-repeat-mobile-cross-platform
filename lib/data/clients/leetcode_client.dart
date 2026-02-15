import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/get_problem_by_question_id_response.dart';

class LeetCodeClient {
  late final HttpLink _link;
  late final GraphQLClient _client;

  LeetCodeClient() {
    _link = HttpLink('https://leetcode.com/graphql');
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
}
