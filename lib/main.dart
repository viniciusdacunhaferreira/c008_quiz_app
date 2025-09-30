import 'dart:developer';

import 'package:c008_quiz_app/models.dart';
import 'package:c008_quiz_app/quiz_widgets.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final quiz = await QuizLoader.loadFromBundle(
    'assets/questions.json',
    // limit: 4,
  );
  log(quiz.toString());
  runApp(MainApp(quiz: quiz));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      home: QuizPage(quiz: quiz),
    );
  }
}
