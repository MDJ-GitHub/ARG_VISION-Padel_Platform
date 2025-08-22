import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;



class AccountsServices {
  static const String _baseUrl = 'http://127.0.0.1:8000/api/auth';

  static Future<http.Response> login(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/login/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(userData);

    return await http.post(url, headers: headers, body: body);
  }

  /// 🔹 SIGN UP with image
 static Future<http.Response> signUp(
    Map<String, dynamic> userData, {
    File? imageFile,
    html.File? webImageFile,
  }) async {

    var url = Uri.parse('$_baseUrl/signup/');
    var request = http.MultipartRequest('POST', url);

    // convert all dynamic values to string
    request.fields.addAll(userData.map((key, value) => MapEntry(key, value.toString())));

    // add image
    if (kIsWeb && webImageFile != null) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(webImageFile);
      await reader.onLoad.first;
      final bytes = reader.result as List<int>;

      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: webImageFile.name),
      );
    } else if (!kIsWeb && imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
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


  static Future<http.Response> sendPasswordResetCode(String email) async {
  // Implement API call to send password reset code
  final response = await http.post(
    Uri.parse('$_baseUrl/passwordreset/'),
    body: {'email': email},
  );
  return response;
}

static Future<http.Response> forgotPasswordChange(Map<String, dynamic> data) async {
  // Implement API call to reset password
  final response = await http.post(
    Uri.parse('$_baseUrl/forgot/change/'),
    body: data,
  );
  return response;
}

static Future<http.Response> forgotPasswordCode(Map<String, dynamic> data) async {
  // Implement API call to reset password
  final response = await http.post(
    Uri.parse('$_baseUrl/forgot/code/'),
    body: data,
  );
  return response;
}

static Future<http.Response> refreshVerify(Map<String, dynamic> data) async {
  // Implement API call to reset password
  final response = await http.post(
    Uri.parse('$_baseUrl/refreshVerify/'),
    body: data,
  );
  return response;
}


}
