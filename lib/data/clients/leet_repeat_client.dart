import 'dart:convert';

import 'package:leet_repeat_mobile_cross_platform/data/contracts/leet_repeat/export_request.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leet_repeat/export_response.dart';
import 'package:leet_repeat_mobile_cross_platform/data/contracts/leet_repeat/import_response.dart';
import 'package:http/http.dart' as http;

class LeetRepeatClient {
  final String baseUrl = 'https://leet-repeat-api.onrender.com/api/progress';

  Future<ExportResponse> export(List<ExportRequest> request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bulk-upsert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.map((e) => e.toJson()).toList()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to export data: ${response.body}');
    }

    return ExportResponse.fromJson(jsonDecode(response.body));
  }

  Future<List<ImportResponse>> import() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Import failed: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => ImportResponse.fromJson(e)).toList();
  }
}