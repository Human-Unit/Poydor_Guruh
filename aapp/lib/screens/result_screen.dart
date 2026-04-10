import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final total = state.questions.length;
    final score = state.score;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final passed = percent >= 70;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (passed ? Colors.green : Colors.red).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 64,
                    color: passed ? Colors.amber : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Great Work!' : 'Keep Practicing!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.white : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                passed ? 'You passed the quiz!' : "Don't give up, try again!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Score card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: passed ? const Color(0xFF4CAF50) : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$score out of $total correct',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total > 0 ? score / total : 0,
                        minHeight: 10,
                        backgroundColor: const Color(0xFF2E2E3E),
                        color: passed ? const Color(0xFF4CAF50) : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(label: 'Correct', value: '$score', color: const Color(0xFF4CAF50)),
                        _StatChip(label: 'Wrong', value: '${total - score}', color: Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (state.questions.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(quizProvider.notifier).startQuiz(state.questions.first.lessonId);
                    context.go('/quiz');
                  },
                  icon: const Icon(Icons.replay, color: Colors.white),
                  label: const Text('Try Again'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
