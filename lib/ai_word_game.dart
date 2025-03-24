import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class AIWordGameScreen extends StatefulWidget {
  final List<String> memoryTexts;
  const AIWordGameScreen({super.key, required this.memoryTexts});

  @override
  _AIWordGameScreenState createState() => _AIWordGameScreenState();
}

class _AIWordGameScreenState extends State<AIWordGameScreen>
    with TickerProviderStateMixin {
  String currentQuestion = "";
  String correctAnswer = "";
  String feedbackMessage = "";
  Color feedbackColor = Colors.transparent;
  int score = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  late AnimationController _animationController;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadGameData();
    _generateQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _generateQuestion() async {
    if (widget.memoryTexts.isEmpty) {
      setState(() {
        currentQuestion = "No memories available.";
      });
      return;
    }

    Random random = Random();
    String memoryText =
        widget.memoryTexts[random.nextInt(widget.memoryTexts.length)];

    String keyword = await _extractKeyword(memoryText);

    if (keyword.isEmpty || !memoryText.contains(keyword)) {
      List<String> words = memoryText.split(" ");
      keyword =
          words.isNotEmpty ? words[random.nextInt(words.length)] : "memory";
    }

    String maskedMemory = memoryText.replaceFirst(keyword, "_____");

    setState(() {
      currentQuestion = "Fill in the blank: \n \"$maskedMemory\"";
      correctAnswer = keyword;
      feedbackMessage = "";
      feedbackColor = Colors.transparent;
    });
  }

  Future<String> _extractKeyword(String text) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/extract_keywords"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        String keyword = jsonDecode(response.body)["keyword"];
        return keyword.isNotEmpty ? keyword : "";
      }
    } catch (e) {
      print("Error calling Flask API: $e");
    }
    return "";
  }

  void _checkAnswer(String input) async {
    if (input.isEmpty) return;

    bool isCorrect =
        input.toLowerCase().trim() == correctAnswer.toLowerCase().trim();

    setState(() {
      if (isCorrect) {
        score += 10;
        correctAnswers++;
        feedbackMessage = "🎉 Correct!";
        feedbackColor = Colors.green;
      } else {
        incorrectAnswers++;
        feedbackMessage = "❌ Wrong! The correct answer was \"$correctAnswer\"";
        feedbackColor = Colors.red;
      }
      _animationController.forward(from: 0.0);
    });

    _controller.clear();
    _generateQuestion();
    await _saveGameData();
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("game_score", score);
    await prefs.setString(
      "game_performance",
      jsonEncode({"correct": correctAnswers, "incorrect": incorrectAnswers}),
    );
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt("game_score") ?? 0;
      Map<String, dynamic> performance =
          jsonDecode(prefs.getString("game_performance") ?? "{}") ?? {};
      correctAnswers = performance["correct"] ?? 0;
      incorrectAnswers = performance["incorrect"] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Word Game")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Your Answer",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _checkAnswer,
              ),
              const SizedBox(height: 10),
              Text(
                feedbackMessage,
                style: TextStyle(fontSize: 18, color: feedbackColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateQuestion,
                child: const Text("Skip"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
