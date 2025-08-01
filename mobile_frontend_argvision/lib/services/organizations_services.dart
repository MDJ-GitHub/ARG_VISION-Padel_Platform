import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganizationsServices {
  static const String _baseUrl = 'http://localhost:8000/api/organizations';

  static Future<List<dynamic>> _fetchMatches(String path) async {
    final url = Uri.parse('$_baseUrl$path');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data from $path');
    }
  }

  static Future<List<dynamic>> fetchPublicMatches() async {
    return _fetchMatches('/matches/list/public/');
  }

  static Future<List<dynamic>> fetchPrivateMatches() async {
    return _fetchMatches('/matches/list/private/');
  }

  // Add more methods as needed:
  // static Future<List<dynamic>> fetchUpcomingMatches() => _fetchMatches('/matches/upcoming/');
}
