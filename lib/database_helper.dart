import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'routines.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // ✅ Create Routines Table
        await db.execute(
          "CREATE TABLE IF NOT EXISTS routines(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, time TEXT, priority INTEGER, createdAt TEXT)",
        );

        // ✅ Create Schedules Table
        await db.execute(
          "CREATE TABLE IF NOT EXISTS schedules(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, time TEXT, createdAt TEXT)",
        );
      },
    );
  }

  // ✅ Insert a Routine
  Future<int> insertRoutine(Map<String, dynamic> routine) async {
    final db = await database;
    int id = await db.insert('routines', routine);
    print("✅ Routine inserted with ID: $id");
    return id;
  }

  // ✅ Retrieve All Routines
  Future<List<Map<String, dynamic>>> getRoutines() async {
    final db = await database;
    final routines = await db.query('routines', orderBy: "time ASC");
    print("📌 Retrieved Routines from DB: $routines");
    return routines;
  }

  // ✅ Delete a Routine
  Future<void> deleteRoutine(int id) async {
    final db = await database;
    await db.delete('routines', where: "id = ?", whereArgs: [id]);
    print("✅ Routine deleted with ID: $id");
  }

  // ✅ Insert a Schedule
  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    int id = await db.insert('schedules', schedule);
    print("✅ Schedule inserted with ID: $id");
    return id;
  }

  // ✅ Retrieve All Schedules
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final db = await database;
    final schedules = await db.query('schedules', orderBy: "date ASC, time ASC");
    print("📌 Retrieved Schedules from DB: $schedules");
    return schedules;
  }

  // ✅ Delete a Schedule
  Future<void> deleteSchedule(int id) async {
    final db = await database;
    await db.delete('schedules', where: "id = ?", whereArgs: [id]);
    print("✅ Schedule deleted with ID: $id");
  }
}
