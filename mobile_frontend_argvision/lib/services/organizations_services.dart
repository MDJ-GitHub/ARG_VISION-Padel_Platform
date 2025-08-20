import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend_argvision/services/storage_service.dart';

class OrganizationsServices {
  static const String _baseUrl = 'http://localhost:8000/api/organizations';

  static Future<List<dynamic>> _organizationsService(String path) async {
    final url = Uri.parse('$_baseUrl$path');

    // Read token from StorageService
    final token = await StorageService.read("access_token");

    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load data from $path: ${response.statusCode} → ${response.body}',
      );
    }
  }

  static Future<List<dynamic>> fetchPublicMatches() async {
    return _organizationsService('/matches/list/public/');
  }

  static Future<List<dynamic>> fetchPrivateMatches() async {
    return _organizationsService('/matches/list/private/');
  }

  static Future<List<dynamic>> fetchDiscussions() async {
    return _organizationsService('/discussions/list/');
  }
}
