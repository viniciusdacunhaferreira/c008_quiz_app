import 'dart:convert';

import 'package:flutter/services.dart';

// A quiz question with a list of possible answers and the indices of the correct answers
class Question {
  const Question({
    required this.question,
    required this.answers,
    required this.correct,
  });
  // The question text
  final String question;
  // List of possible answers
  final List<String> answers;
  // The (zero-based) indices of the correct answers
  final List<int> correct;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      // Go from 1-based (JSON file) to 0-based (Dart code)
      correct: List<int>.from(json['correct']).map((e) => e - 1).toList(),
    );
  }

  @override
  String toString() {
    return '''
  question
     |> $question
  answers
${answers.map((a) => '     |> $a').join('\n')}
  correct
     |> $correct''';
  }
}

// A quiz with a list of questions
class Quiz {
  final List<Question> questions;
  const Quiz({required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json, {int? limit}) {
    final questionsJson = json['questions'] as List<dynamic>;
    return Quiz(
      questions:
          questionsJson
              .map((q) => Question.fromJson(q as Map<String, dynamic>))
              .take(limit ?? questionsJson.length)
              .toList(),
    );
  }

  @override
  String toString() {
    final separator = '-' * 80;
    return '''
$separator
${questions.join('\n$separator\n')}
$separator
    ''';
  }
}

// A helper class to load a quiz from a JSON file in the assets folder
class QuizLoader {
  static Future<Quiz> loadFromBundle(String path, {int? limit}) async {
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString);
    return Quiz.fromJson(json, limit: limit);
  }
}
