import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(null);

  Future<User?> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = User.fromMap(jsonDecode(userJson));
      state = user;
      return user;
    }
    return null;
  }

  Future<void> register(String email, String password) async {
    final token = await _apiService.register(email, password);
    if (token != null) {
      final newUser = User(email: email, token: token);
      state = newUser;
      await _saveUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    }
  }

  Future<void> login(String email, String password) async {
    final token = await _apiService.login(email, password);
    if (token != null) {
      final newUser = User(email: email, token: token);
      state = newUser;
      await _saveUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    }
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('jwt_token');
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toMap()));
  }

  Future<Map<String, dynamic>?> getProgress() async {
    try {
      return await _apiService.getProgress();
    } catch (e) {
      return null;
    }
  }
}
