import 'lesson.dart';

class Question {
  final int id;
  final int lessonId;
  final Lesson? lesson;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? explanation;
  final int correctAnswer;

  Question({
    required this.id,
    required this.lessonId,
    this.lesson,
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.explanation,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      lessonId: json['lesson_id'] ?? 0,
      lesson: json['lesson'] != null ? Lesson.fromJson(json['lesson']) : null,
      text: json['text'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      explanation: json['explanation'],
      correctAnswer: json['correct_answer'] ?? 0,
    );
  }
}
