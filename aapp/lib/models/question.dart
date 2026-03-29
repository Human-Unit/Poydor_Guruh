class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correct_answer;
  final String? imageUrl;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correct_answer,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correct_answer: json['correct_answer'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correct_answer,
      'imageUrl': imageUrl,
    };
  }
}
