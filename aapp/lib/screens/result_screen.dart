import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.stars, size: 120, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Quiz Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Your Score', style: TextStyle(fontSize: 20, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        '${quizState.score} / ${quizState.questions.length}',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ref.read(quizProvider.notifier).startQuiz();
                  context.go('/quiz');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('RETRY', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('BACK TO HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
