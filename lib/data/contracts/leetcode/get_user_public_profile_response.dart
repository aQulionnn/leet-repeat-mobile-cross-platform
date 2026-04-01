class GetUserPublicProfileResponse {
  final String username;
  final String? githubUrl;
  final int ranking;
  final String? userAvatar;

  GetUserPublicProfileResponse({
    required this.username,
    required this.githubUrl,
    required this.ranking,
    required this.userAvatar,
  });

  factory GetUserPublicProfileResponse.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>;
    return GetUserPublicProfileResponse(
      username: json['username'],
      githubUrl: json['githubUrl'],
      ranking: profile['ranking'],
      userAvatar: profile['userAvatar'],
    );
  }
}
