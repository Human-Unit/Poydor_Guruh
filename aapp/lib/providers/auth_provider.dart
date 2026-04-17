import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  // Use the global API provider
  final apiService = ref.read(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthNotifier extends StateNotifier<User?> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(null) {
    _apiService.onUnauthorizedStream.listen((_) {
      logout();
    });
  }

  Future<User?> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = User.fromJson(jsonDecode(userJson));
      state = user;
      return user;
    }
    return null;
  }

  Future<void> register(String name, String username, String email, String password) async {
    final status = await _apiService.register(name: name, username: username, email: email, password: password);
    if (status != null) {
      // Backend returns status but might not return token directly. Proceed to login or handle status.
      // Let's just login automatically if registration succeeds.
      await login(email, password);
    }
  }

  Future<void> login(String email, String password) async {
    final responseData = await _apiService.login(email, password);
    if (responseData != null) {
      final token = responseData['token'] as String;
      final userData = responseData['user'] as Map<String, dynamic>?;
      
      User newUser;
      if (userData != null) {
        newUser = User.fromJson(userData, token: token);
      } else {
        // Fallback for admin or unexpected response structure
        newUser = User(
          id: 0,
          name: responseData['role'] == 'admin' ? 'Admin' : '',
          username: '',
          email: email,
          role: responseData['role'] ?? 'user',
          token: token,
        );
      }

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
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>?> getProgress() async {
    try {
      return await _apiService.getProgress();
    } catch (e) {
      return null;
    }
  }
}
