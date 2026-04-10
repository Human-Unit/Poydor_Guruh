import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import '../models/lesson.dart';
import '../models/question.dart';

class ApiService {
  late final Dio _dio;
  
  // Dynamic base URL based on platform
  static String get _baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      } else {
        return 'http://localhost:8080';
      }
    } catch (e) {
      // Fallback for Web
      return 'http://localhost:8080';
    }
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: "application/json",
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['token'];
      }
    } on DioException catch (e) {
      throw Exception('Failed to login: ${e.response?.data?['error'] ?? e.message}');
    }
    return null;
  }

  Future<String?> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Trying with 'PasswordHash' matching the Go exact model name.
      // Often frameworks map fields exactly, but we also include 'password' just in case.
      final response = await _dio.post(
        '/users/register',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration sometimes returns a token, or user object.
        // Assuming we need to login after, or it returns 'status'.
        return response.data['status'];
      }
    } on DioException catch (e) {
      throw Exception('Failed to register: ${e.response?.data?['error'] ?? e.message}');
    }
    return null;
  }

  Future<List<Lesson>> getLessons() async {
    try {
      final response = await _dio.get('/users/lessons');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Lesson.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load lessons: ${e.message}');
    }
  }

  Future<List<Question>> getQuestions(int lessonId) async {
    try {
      final response = await _dio.get('/users/lessons/$lessonId/questions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Question.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load questions: ${e.message}');
    }
  }

  Future<void> submitResult(List<Map<String, dynamic>> answers) async {
    try {
      // Expects array format: {"answers": [{"question_id": 1, "selected_answer": 2}]}
      await _dio.post(
        '/users/quiz/submit',
        data: {'answers': answers},
      );
    } on DioException catch (e) {
      throw Exception('Failed to submit result: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    try {
      final response = await _dio.get('/users/me/progress');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      throw Exception('Failed to load progress: ${e.message}');
    }
  }
}
