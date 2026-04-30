class RecentAcSubmission {
  final String titleSlug;
  final String title;

  RecentAcSubmission({required this.titleSlug, required this.title});

  factory RecentAcSubmission.fromJson(Map<String, dynamic> json) =>
      RecentAcSubmission(titleSlug: json['titleSlug'], title: json['title']);
}
