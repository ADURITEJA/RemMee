import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class RoutinesPage extends StatefulWidget {
  @override
  _RoutinesPageState createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool _isPriority = false;
  List<Map<String, dynamic>> _routines = [];

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final routines = await _dbHelper.getRoutines();
    setState(() {
      _routines = routines;
    });
  }

  Future<void> _addRoutine() async {
    if (_titleController.text.isNotEmpty && _selectedTime != null) {
      DateTime now = DateTime.now();
      DateTime routineDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      Map<String, dynamic> newRoutine = {
        'title': _titleController.text,
        'time': _selectedTime!.format(context),
        'priority': _isPriority ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      int routineId = await _dbHelper.insertRoutine(newRoutine);

      if (_isPriority) {
        await NotificationService().scheduleNotification(
          routineId,
          "Priority Routine",
          newRoutine['title'],
          routineDateTime,
        );
      } else {
        await NotificationService().scheduleNotification(
          routineId,
          "Routine Reminder",
          newRoutine['title'],
          routineDateTime,
        );
      }

      _titleController.clear();
      _selectedTime = null;
      _isPriority = false;
      _loadRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Routines")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Routine Name"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
              child: Text(
                _selectedTime == null
                    ? "Pick Time"
                    : _selectedTime!.format(context),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isPriority,
                  onChanged: (value) {
                    setState(() {
                      _isPriority = value!;
                    });
                  },
                ),
                Text("Priority Routine"),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addRoutine,
              child: Text("Add Routine"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _routines.length,
                itemBuilder: (context, index) {
                  final routine = _routines[index];
                  return Card(
                    child: ListTile(
                      title: Text(routine['title']),
                      subtitle: Text("Time: ${routine['time']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _dbHelper.deleteRoutine(routine['id']);
                          _loadRoutines();
                        },
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