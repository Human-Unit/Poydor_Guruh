import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';

final lessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  final apiService = ApiService();
  return apiService.getLessons();
});
