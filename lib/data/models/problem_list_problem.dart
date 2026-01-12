class ProblemListProblem {
  int? id;
  int problemId;
  int problemListId;

  ProblemListProblem({
    this.id,
    required this.problemId,
    required this.problemListId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'problem_id': problemId,
    'problem_list_id': problemListId,
  };

  factory ProblemListProblem.fromJson(Map<String, dynamic> json) =>
      ProblemListProblem(
        id: json['id'],
        problemId: json['problem_id'],
        problemListId: json['problem_list_id'],
      );
}