import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_card.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);

    if (quizState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load questions'),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (quizState.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/result');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = quizState.questions[quizState.currentQuestionIndex];
    final progress = (quizState.currentQuestionIndex + 1) / quizState.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${quizState.currentQuestionIndex + 1} of ${quizState.questions.length}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 32),
              Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: currentQuestion.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final isSelected = quizState.selectedOptionIndex == index;
                    bool isCorrect = false;
                    bool isWrong = false;

                    if (quizState.isAnswerChecked) {
                      if (index == currentQuestion.correct_answer) {
                        isCorrect = true;
                      } else if (isSelected) {
                        isWrong = true;
                      }
                    }

                    return OptionCard(
                      text: currentQuestion.options[index],
                      isSelected: isSelected,
                      isCorrect: isCorrect,
                      isWrong: isWrong,
                      onTap: () => quizNotifier.selectOption(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: quizState.isAnswerChecked ? Colors.green : Colors.blue,
                ),
                onPressed: () {
                  if (!quizState.isAnswerChecked) {
                    quizNotifier.checkAnswer();
                  } else {
                    quizNotifier.nextQuestion();
                  }
                },
                child: Text(
                  quizState.isAnswerChecked ? 'CONTINUE' : 'CHECK',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
