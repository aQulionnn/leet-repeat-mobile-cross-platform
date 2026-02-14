import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leetcode/leetcode_question_details_response.dart';

class LeetCodeClient {
  late final HttpLink _link;
  late final GraphQLClient _client;

  LeetCodeClient() {
    _link = HttpLink('https://leetcode.com/graphql');
    _client = GraphQLClient(link: _link, cache: GraphQLCache());
  }

  Future<LeetCodeQuestionDetailsResponse?> getQuestionDetails(String titleSlug) async {
    final response = await _client.query(
      QueryOptions(
        document: gql(r'''
          query questionDetail($titleSlug: String!) {
            question(titleSlug: $titleSlug) {
              questionId
              title
              difficulty
            }
          } 
        '''),
        variables: {'titleSlug': titleSlug},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (response.hasException) {
      throw response.exception!;
    }

    final json = response.data?['question'];
    if (json == null) return null;

    return LeetCodeQuestionDetailsResponse.fromJson(json);
  }
}