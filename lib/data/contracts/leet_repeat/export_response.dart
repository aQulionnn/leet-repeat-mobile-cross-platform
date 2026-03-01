class ExportResponse {
  final String message;
  final int count;

  ExportResponse({required this.message, required this.count});

  factory ExportResponse.fromJson(Map<String, dynamic> json) => ExportResponse(
    message: json['message'],
    count: json['count'],
  );
}