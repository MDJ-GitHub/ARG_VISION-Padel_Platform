import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganizationsServices {
  static const String _baseUrl = 'http://127.0.0.1:8000/api/auth';

    static Future<http.Response> login(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/login/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(userData);

    return await http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> signUp(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/signup/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(userData);

    return await http.post(url, headers: headers, body: body);
  }

    static Future<http.Response> verify(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/verify/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(userData);

    return await http.post(url, headers: headers, body: body);
  }

    static Future<http.Response> refresh(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/refresh/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(userData);

    return await http.post(url, headers: headers, body: body);
  }
}

