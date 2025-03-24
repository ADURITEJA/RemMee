import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class PriorityAlertScreen extends StatelessWidget {
  final String routineName;
  final String time;

  PriorityAlertScreen({required this.routineName, required this.time});

  void _closeAlert(BuildContext context) {
  Navigator.of(context).pop();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Priority Routine Alert",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 10),
                Text(routineName, style: TextStyle(fontSize: 18)),
                SizedBox(height: 5),
                Text("Time: $time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _closeAlert(context),
                  child: Text("Completed"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
