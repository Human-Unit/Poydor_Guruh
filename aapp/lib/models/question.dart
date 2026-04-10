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
      id: json['ID'] ?? json['id'] ?? 0,
      lessonId: json['LessonID'] ?? json['lesson_id'] ?? 0,
      lesson: json['Lesson'] != null ? Lesson.fromJson(json['Lesson']) : null,
      text: json['Text'] ?? json['text'] ?? '',
      optionA: json['OptionA'] ?? json['option_a'] ?? '',
      optionB: json['OptionB'] ?? json['option_b'] ?? '',
      optionC: json['OptionC'] ?? json['option_c'] ?? '',
      optionD: json['OptionD'] ?? json['option_d'] ?? '',
      explanation: json['Explanation'] ?? json['explanation'],
      correctAnswer: json['CorrectAnswer'] ?? json['correct_answer'] ?? 0,
    );
  }
}
