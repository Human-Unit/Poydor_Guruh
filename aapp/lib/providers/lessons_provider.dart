import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';

import 'api_provider.dart';

final lessonsProvider = AsyncNotifierProvider<LessonsNotifier, List<Lesson>>(() {
  return LessonsNotifier();
});

class LessonsNotifier extends AsyncNotifier<List<Lesson>> {
  late final ApiService _apiService;
  Timer? _timer;

  @override
  FutureOr<List<Lesson>> build() {
    _apiService = ref.read(apiServiceProvider);
    // Start polling when the provider is initialized
    _startPolling();
    
    // Cleanup timer when the provider is disposed
    ref.onDispose(() {
      _timer?.cancel();
    });

    return _fetchLessons();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final lessons = await _fetchLessons();
      // Only update state if it's still active and data has changed
      if (state.hasValue && state.value != null) {
        state = AsyncValue.data(lessons);
      }
    });
  }

  Future<List<Lesson>> _fetchLessons() async {
    try {
      return await _apiService.getLessons();
    } catch (e) {
      // If it's a first load failure, throw it
      if (!state.hasValue) rethrow;
      // Otherwise keep old data but maybe log the error
      return state.value ?? [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLessons());
  }
}
