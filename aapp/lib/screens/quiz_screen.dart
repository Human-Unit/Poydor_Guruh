import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<QuizState>(quizProvider, (prev, next) {
      if (next.isFinished && (prev == null || !prev.isFinished)) {
        context.go('/result');
      }
    });

    final state = ref.watch(quizProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No questions found', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))));
    }

    final q = state.questions[state.currentQuestionIndex];
    final options = [q.optionA, q.optionB, q.optionC, q.optionD];
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFF2E2E3E),
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${state.currentQuestionIndex + 1}/${state.questions.length}',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  const SizedBox(height: 12),
                  Text(
                    q.text,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(options.length, (i) {
                    final isSelected = state.selectedOptionIndex == i;
                    final isChecked = state.isAnswerChecked;
                    final isCorrect = isChecked && i == q.correctAnswer;
                    final isWrong = isChecked && isSelected && i != q.correctAnswer;

                    Color borderColor = const Color(0xFF2E2E3E);
                    Color bgColor = const Color(0xFF1E1E2E);
                    Color textColor = Colors.white;
                    Widget? trailingIcon;

                    if (isCorrect) {
                      borderColor = const Color(0xFF4CAF50);
                      bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.12);
                      trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF4CAF50));
                    } else if (isWrong) {
                      borderColor = Colors.red;
                      bgColor = Colors.red.withValues(alpha: 0.1);
                      textColor = Colors.red;
                      trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                    } else if (isSelected) {
                      borderColor = const Color(0xFF6C63FF);
                      bgColor = const Color(0xFF6C63FF).withValues(alpha: 0.12);
                    }

                    return GestureDetector(
                      onTap: isChecked ? null : () => ref.read(quizProvider.notifier).selectOption(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected || isCorrect ? borderColor.withValues(alpha: 0.2) : const Color(0xFF2E2E3E),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: TextStyle(
                                    color: isCorrect ? const Color(0xFF4CAF50) : isWrong ? Colors.red : isSelected ? const Color(0xFF6C63FF) : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(options[i], style: TextStyle(color: textColor, fontSize: 15))),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    );
                  }),
                  if (state.isAnswerChecked && q.explanation != null && q.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2E3E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Explanation', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(q.explanation!, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.selectedOptionIndex == null
                      ? null
                      : () {
                          if (!state.isAnswerChecked) {
                            ref.read(quizProvider.notifier).checkAnswer();
                          } else {
                            ref.read(quizProvider.notifier).nextQuestion();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isAnswerChecked
                        ? (state.selectedOptionIndex == q.correctAnswer ? const Color(0xFF4CAF50) : Colors.red)
                        : const Color(0xFF6C63FF),
                    disabledBackgroundColor: const Color(0xFF2E2E3E),
                  ),
                  child: Text(
                    state.isAnswerChecked ? 'CONTINUE' : 'CHECK',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
