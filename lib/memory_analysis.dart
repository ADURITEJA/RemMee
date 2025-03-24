import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MemoryAnalysisPage extends StatefulWidget {
  @override
  _MemoryAnalysisPageState createState() => _MemoryAnalysisPageState();
}

class _MemoryAnalysisPageState extends State<MemoryAnalysisPage> {
  List<MemoryData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadMemoryAnalysis();
  }

  /// **Loads Memory Analysis Based on AI Word Game Performance**
  Future<void> _loadMemoryAnalysis() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int correct = prefs.getInt("correct_answers") ?? 0;
      int incorrect = prefs.getInt("incorrect_answers") ?? 0;
      int total = correct + incorrect;

      if (total == 0) {
        setState(() {
          _chartData = _defaultChartData();
        });
        return;
      }

      setState(() {
        _chartData = [
          MemoryData(
            "Strongly Remembered",
            ((correct / total) * 100).clamp(1, 100),
            Colors.green,
          ),
          MemoryData(
            "Forgotten",
            ((incorrect / total) * 100).clamp(1, 100),
            Colors.red,
          ),
        ];
      });
    } catch (e) {
      print("Error loading memory analysis: $e");
    }
  }

  /// **Default Data if No Memory Analysis Found**
  List<MemoryData> _defaultChartData() {
    return [
      MemoryData("Strongly Remembered", 50, Colors.green),
      MemoryData("Forgotten", 50, Colors.red),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Analysis"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "AI-Based Memory Recall Analysis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              child:
                  _chartData.isNotEmpty
                      ? SfCircularChart(
                        title: ChartTitle(text: "Memory Recall Percentage"),
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                        ),
                        series: <DoughnutSeries<MemoryData, String>>[
                          DoughnutSeries<MemoryData, String>(
                            dataSource: _chartData,
                            pointColorMapper:
                                (MemoryData data, _) => data.color,
                            xValueMapper: (MemoryData data, _) => data.category,
                            yValueMapper:
                                (MemoryData data, _) => data.percentage,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                            ),
                          ),
                        ],
                      )
                      : const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryData {
  final String category;
  final double percentage;
  final Color color;

  MemoryData(this.category, this.percentage, this.color);
}
