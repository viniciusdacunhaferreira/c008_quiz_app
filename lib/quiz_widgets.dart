import 'package:c008_quiz_app/models.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: QuizQuestion(quiz: quiz),
          ),
        ),
      ),
    );
  }
}

class QuizQuestion extends StatefulWidget {
  const QuizQuestion({super.key, required this.quiz});
  final Quiz quiz;
  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  // all questions shuffled in random order
  late final List<Question> shuffledQuestions = List.from(widget.quiz.questions)
    // Comment out to disable shuffling
    ..shuffle();

  // All the previous answers for the quiz
  // This is a List<List<int>> because there are multiple questions and a single question can have multiple answers
  List<List<int>> previousAnswers = [];
  // selected answers for the current question
  List<int> currentAnswers = [];
  // false during answer selection, true during answer verification
  bool isVerifying = false;

  // true if the user is on the last question
  bool get onLastQuestion =>
      previousAnswers.length == shuffledQuestions.length - 1;

  // Helper methods to count the correct answers (use this to display the score)
  int? correctAnswersCountMaybe() {
    if (!isVerifying) {
      return null;
    }
    final allAnswers = [...previousAnswers, currentAnswers];
    if (allAnswers.length != shuffledQuestions.length) {
      return null;
    }
    return correctAnswersCount(allAnswers);
  }

  int correctAnswersCount(List<List<int>> allAnswers) {
    assert(allAnswers.length == shuffledQuestions.length);
    int correct = 0;
    for (int i = 0; i < shuffledQuestions.length; i++) {
      if (allAnswers[i].length == shuffledQuestions[i].correct.length &&
          allAnswers[i].every(
            (answer) => shuffledQuestions[i].correct.contains(answer),
          )) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = shuffledQuestions[previousAnswers.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // * Header (question and progress)
        ColoredBox(
          // Use surface color (not transparent) to avoid scrollable content appearing below the header
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: QuizQuestionProgress(
              completedCount: previousAnswers.length,
              totalCount: widget.quiz.questions.length,
              correctCount: correctAnswersCountMaybe(),
              question: currentQuestion.question,
            ),
          ),
        ),
        // * Body (answers)
        Expanded(
          child: switch (currentQuestion.correct.length) {
            1 => ListView.builder(
              itemCount: currentQuestion.answers.length,
              itemBuilder: (context, index) {
                return QuizRadioListTile(
                  key: ValueKey('q_${previousAnswers.length}_a_$index'),
                  answer: currentQuestion.answers.elementAt(index),
                  currentIndex: index,
                  selectedIndex: currentAnswers.firstOrNull,
                  onChanged: (int value) {
                    setState(() => currentAnswers = [value]);
                  },
                  isVerifying: isVerifying,
                  isCorrect: currentQuestion.correct.contains(index),
                );
              },
            ),
            _ => ListView.builder(
              itemCount: currentQuestion.answers.length,
              itemBuilder: (context, index) {
                return QuizCheckboxListTile(
                  key: ValueKey('q_${previousAnswers.length}_a_$index'),
                  answer: currentQuestion.answers.elementAt(index),
                  isSelected: currentAnswers.contains(index),
                  onChanged: (bool value) {
                    setState(() {
                      switch (value) {
                        case true:
                          currentAnswers.add(index);
                        case false:
                          currentAnswers.remove(index);
                      }
                    });
                  },
                  isVerifying: isVerifying,
                  isCorrect: currentQuestion.correct.contains(index),
                );
              },
            ),
          },
        ),
        // * Footer (submit button)
        ColoredBox(
          // Use surface color (not transparent) to avoid scrollable content appearing below the header
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ElevatedButton(
              onPressed:
                  currentAnswers.isEmpty
                      ? null
                      : () {
                        setState(() {
                          if (!isVerifying) {
                            isVerifying = true;
                            return;
                          }

                          if (onLastQuestion) {
                            previousAnswers = [];
                            currentAnswers = [];
                            isVerifying = false;
                            return;
                          }

                          previousAnswers.add(currentAnswers);
                          currentAnswers = [];
                          isVerifying = false;
                        });
                      },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(switch (!isVerifying) {
                  true => 'Submit',
                  false => switch (onLastQuestion) {
                    true => 'Try Again',
                    false => 'Next Question',
                  },
                }, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class QuizQuestionProgress extends StatelessWidget {
  const QuizQuestionProgress({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.correctCount,
    required this.question,
  });
  final int completedCount;
  final int totalCount;
  final int? correctCount;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question ${completedCount + 1} of $totalCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (correctCount != null)
              Text(
                'You scored $correctCount out of $totalCount (${(correctCount! / totalCount * 100).round()}%)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(value: (completedCount + 1) / totalCount),
        SizedBox(height: 24),
        Text(question, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

// Radio list tile for a single answer question
class QuizRadioListTile extends StatelessWidget {
  const QuizRadioListTile({
    super.key,
    required this.answer,
    required this.currentIndex,
    required this.selectedIndex,
    required this.onChanged,
    required this.isVerifying,
    required this.isCorrect,
  });
  final String answer;
  final int currentIndex;
  final int? selectedIndex;
  final ValueChanged<int>? onChanged;
  final bool isVerifying;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(
      enabled: !isVerifying,
      value: currentIndex,
      title: Text(answer, style: Theme.of(context).textTheme.titleMedium),
      // ignore: deprecated_member_use
      groupValue: selectedIndex,
      // ignore: deprecated_member_use
      onChanged: (value) {
        if (onChanged != null) onChanged!.call(value!);
      },

      tileColor: switch (isVerifying) {
        false => null,
        true => switch (isCorrect) {
          true => Colors.green,
          false => currentIndex == selectedIndex ? Colors.red : null,
        },
      },
    );
  }
}

// Checkbox list tile for a multiple answer question
class QuizCheckboxListTile extends StatelessWidget {
  const QuizCheckboxListTile({
    super.key,
    required this.answer,
    required this.isSelected,
    required this.onChanged,
    required this.isVerifying,
    required this.isCorrect,
  });
  final String answer;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final bool isVerifying;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      enabled: !isVerifying,
      onChanged: (value) {
        onChanged?.call(value!);
      },
      value: isSelected,
      title: Text(answer, style: Theme.of(context).textTheme.titleMedium),
      tileColor: switch (isVerifying) {
        false => null,
        true => switch (isCorrect) {
          true => Colors.green,
          false => isSelected ? Colors.red : null,
        },
      },
    );
  }
}
