import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return QuizNotifier(apiService);
});

class QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final int score;
  final bool isFinished;
  final int? selectedOptionIndex;
  final bool isAnswerChecked;
  final bool isLoading;
  final List<Map<String, dynamic>> answers;

  QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.isFinished = false,
    this.selectedOptionIndex,
    this.isAnswerChecked = false,
    this.isLoading = false,
    this.answers = const [],
  });

  QuizState cloneWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    int? score,
    bool? isFinished,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    bool? isAnswerChecked,
    bool? isLoading,
    List<Map<String, dynamic>>? answers,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      isFinished: isFinished ?? this.isFinished,
      selectedOptionIndex: clearSelectedOption ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      isLoading: isLoading ?? this.isLoading,
      answers: answers ?? this.answers,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final ApiService _apiService;

  QuizNotifier(this._apiService) : super(QuizState(questions: []));

  Future<void> startQuiz(int lessonId) async {
    state = state.cloneWith(
        isLoading: true,
        isFinished: false,
        currentQuestionIndex: 0,
        score: 0,
        clearSelectedOption: true,
        isAnswerChecked: false,
        answers: []);
    try {
      final questions = await _apiService.getQuestions(lessonId);
      state = QuizState(questions: questions, isLoading: false, answers: []);
    } catch (e) {
      state = state.cloneWith(isLoading: false);
    }
  }

  void selectOption(int index) {
    if (state.isAnswerChecked) return;
    state = state.cloneWith(selectedOptionIndex: index, clearSelectedOption: false);
  }

  void checkAnswer() {
    if (state.selectedOptionIndex == null || state.isAnswerChecked) return;

    final currentQuestion = state.questions[state.currentQuestionIndex];
    final isCorrect = state.selectedOptionIndex == currentQuestion.correctAnswer;
    
    final newAnswers = List<Map<String, dynamic>>.from(state.answers);
    newAnswers.add({
      'question_id': currentQuestion.id,
      'selected_answer': state.selectedOptionIndex,
    });

    state = state.cloneWith(
      isAnswerChecked: true,
      score: isCorrect ? state.score + 1 : state.score,
      answers: newAnswers,
    );
  }

  Future<void> nextQuestion() async {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.cloneWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        clearSelectedOption: true,
        isAnswerChecked: false,
      );
    } else {
      state = state.cloneWith(isFinished: true);
      try {
        if (state.questions.isNotEmpty) {
          final lessonId = state.questions.first.lessonId;
          final questionIds = state.questions.map((q) => q.id).toList();
          final selectedAnswers = state.answers.map((a) => a['selected_answer'] as int).toList();

          await _apiService.submitResult(
            lessonId: lessonId,
            questionIds: questionIds,
            answers: selectedAnswers,
          );
        }
      } catch (e) {
        // Handle error if needed
      }
    }
  }
}
