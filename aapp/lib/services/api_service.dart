import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<String?> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<List<Question>> getQuestions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/questions'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }

  Future<void> submitResult(int score, int total) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit'),
      headers: await _headers(),
      body: jsonEncode({'score': score, 'total': total}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit result: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/progress'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load progress: ${response.statusCode}');
    }
  }
}
