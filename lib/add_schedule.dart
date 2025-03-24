import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class AddSchedulePage extends StatefulWidget {
  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final TextEditingController _scheduleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _addSchedule() async {
    if (_scheduleController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all details")),
      );
      return;
    }

    await _dbHelper.insertSchedule({
      "title": _scheduleController.text,
      "date": DateFormat('yyyy-MM-dd').format(_selectedDate!), // ✅ Store date
      "time": _selectedTime!.format(context), // ✅ Store time
      "createdAt": DateTime.now().toString(),
    });

    Navigator.pop(context, true); // ✅ Return to previous screen and refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Schedule")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _scheduleController,
              decoration: InputDecoration(labelText: "Schedule Name"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickTime,
              child: Text(_selectedTime == null ? "Select Time" : _selectedTime!.format(context)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSchedule,
              child: Text("Add Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}
