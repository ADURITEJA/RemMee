import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'add_schedule.dart';

class SchedulesPage extends StatefulWidget {
  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _schedules = [];
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {}; // Stores schedules by date

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // ✅ Show today's schedules by default
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await _dbHelper.getSchedules();
    setState(() {
      _schedules = schedules;
      _events = _groupSchedulesByDate(schedules);
    });
  }

  // ✅ Group schedules by date for event markers
  Map<DateTime, List<Map<String, dynamic>>> _groupSchedulesByDate(List<Map<String, dynamic>> schedules) {
    Map<DateTime, List<Map<String, dynamic>>> data = {};

    for (var schedule in schedules) {
      DateTime scheduleDate = DateTime.parse(schedule["date"]);
      DateTime formattedDate = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);

      if (!data.containsKey(formattedDate)) {
        data[formattedDate] = [];
      }
      data[formattedDate]!.add(schedule);
    }

    // ✅ Sort schedules by time for each date
    data.forEach((key, value) {
      value.sort((a, b) => a['time'].compareTo(b['time']));
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedules")),
      body: Column(
        children: [
          // ✅ Calendar View (Fixed)
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month, // ✅ Force month view only
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              });
            },
            eventLoader: (day) {
              DateTime formattedDate = DateTime(day.year, day.month, day.day);
              return _events[formattedDate] ?? [];
            },

            // ✅ Show a single red dot under dates with schedules
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                DateTime formattedDate = DateTime(date.year, date.month, date.day);
                if (_events.containsKey(formattedDate) && _events[formattedDate]!.isNotEmpty) {
                  return Positioned(
                    bottom: 5,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),

          SizedBox(height: 10),

          // ✅ List of Schedules (Only for Selected Date)
          Expanded(
            child: _events[_selectedDay] == null || _events[_selectedDay]!.isEmpty
                ? Center(child: Text("No schedules for this day"))
                : ListView.builder(
                    itemCount: _events[_selectedDay]!.length,
                    itemBuilder: (context, index) {
                      final schedule = _events[_selectedDay]![index];
                      return ListTile(
                        title: Text(schedule['title']),
                        subtitle: Text("Time: ${schedule['time']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _dbHelper.deleteSchedule(schedule['id']);
                            _loadSchedules();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSchedulePage()),
          );
          if (result == true) {
            _loadSchedules();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
