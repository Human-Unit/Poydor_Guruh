class QuizResult {
  final int score;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      score: map['score']?.toInt() ?? 0,
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}
