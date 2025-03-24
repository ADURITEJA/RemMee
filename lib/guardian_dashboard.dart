import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart'; // Import notification service

class GuardianDashboard extends StatefulWidget {
  @override
  _GuardianDashboardState createState() => _GuardianDashboardState();
}

class _GuardianDashboardState extends State<GuardianDashboard> {
  List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? selectedTime;
  Timer? _taskTimer;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.init(); // Initialize notifications
    _loadTasks();
  }

  /// **Loads Saved Tasks**
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedTasks = prefs.getStringList("tasks") ?? [];
    setState(() {
      tasks = storedTasks.map((t) => Task.fromJson(jsonDecode(t))).toList();
    });
  }

  /// **Saves Tasks in Local Storage**
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskJsonList = tasks.map((t) => jsonEncode(t.toJson())).toList();
    prefs.setStringList("tasks", taskJsonList);
  }

  /// **Handles Task Addition**
  void _addTask() async {
    if (_taskController.text.isEmpty || selectedTime == null) return;

    DateTime now = DateTime.now();
    DateTime scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    Task newTask = Task(_taskController.text, scheduledDateTime);
    setState(() {
      tasks.add(newTask);
      _taskController.clear();
      selectedTime = null;
    });

    _saveTasks();

    // Schedule Notification
    await _notificationService.scheduleNotification(
      tasks.length, // Unique ID for each task
      "Task Reminder",
      "It's time for: ${newTask.title}",
      scheduledDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Task scheduled for ${selectedTime!.format(context)}")),
    );
  }

  /// **Removes Task**
  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  /// **Shows Task Reminder as Popup**
  void _showTaskReminder(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Task Reminder"),
        content: Text("It's time for: ${task.title}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  /// **Pick Time for Task**
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => selectedTime = pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guardian Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Set Tasks for the Patient", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: "Enter a task...",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: _pickTime,
                ),
              ),
            ),
            SizedBox(height: 10),
            selectedTime != null
                ? Text("Task Time: ${selectedTime!.format(context)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                : Container(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: Text("Add Task"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(tasks[index].title),
                      subtitle: Text("Time: ${tasks[index].time.hour}:${tasks[index].time.minute}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **Task Model**
class Task {
  final String title;
  final DateTime time;

  Task(this.title, this.time);

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(json['title'], DateTime.parse(json['time']));
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'time': time.toIso8601String()};
  }
}