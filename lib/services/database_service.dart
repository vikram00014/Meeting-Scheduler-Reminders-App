import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meeting.dart';

/// Database service for local storage of meetings using SQLite
/// Implements offline-first architecture with full CRUD operations
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Get database instance, initialize if not exists
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meetings.db');
    return _database!;
  }

  /// Initialize the database and create tables
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
    CREATE TABLE meetings (
      id $idType,
      title $textType,
      dateTime $textType,
      durationMinutes $intType,
      description $textTypeNullable,
      participants $textType,
      category $textType,
      reminderEnabled $intType,
      reminderMinutesBefore $textType,
      createdAt $textType,
      updatedAt $textTypeNullable
    )
    ''');

    // Create index on dateTime for faster queries
    await db.execute('''
    CREATE INDEX idx_meetings_datetime ON meetings(dateTime)
    ''');
  }

  /// Insert a new meeting into the database
  Future<Meeting> createMeeting(Meeting meeting) async {
    final db = await instance.database;
    await db.insert('meetings', meeting.toMap());
    return meeting;
  }

  /// Retrieve a meeting by ID
  Future<Meeting?> getMeeting(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'meetings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Meeting.fromMap(maps.first);
    }
    return null;
  }

  /// Get all meetings from the database
  Future<List<Meeting>> getAllMeetings() async {
    final db = await instance.database;
    const orderBy = 'dateTime ASC';
    final result = await db.query('meetings', orderBy: orderBy);

    return result.map((json) => Meeting.fromMap(json)).toList();
  }

  /// Get meetings for a specific date
  Future<List<Meeting>> getMeetingsForDate(DateTime date) async {
    final db = await instance.database;

    // Create start and end of day timestamps
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.query(
      'meetings',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dateTime ASC',
    );

    return result.map((json) => Meeting.fromMap(json)).toList();
  }

  /// Get meetings within a date range
  Future<List<Meeting>> getMeetingsInRange(DateTime start, DateTime end) async {
    final db = await instance.database;

    final result = await db.query(
      'meetings',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dateTime ASC',
    );

    return result.map((json) => Meeting.fromMap(json)).toList();
  }

  /// Get upcoming meetings (from now onwards)
  Future<List<Meeting>> getUpcomingMeetings({int limit = 10}) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    final result = await db.query(
      'meetings',
      where: 'dateTime >= ?',
      whereArgs: [now],
      orderBy: 'dateTime ASC',
      limit: limit,
    );

    return result.map((json) => Meeting.fromMap(json)).toList();
  }

  /// Update an existing meeting
  Future<int> updateMeeting(Meeting meeting) async {
    final db = await instance.database;

    // Create updated meeting with new updatedAt timestamp
    final updatedMeeting = meeting.copyWith(updatedAt: DateTime.now());

    return db.update(
      'meetings',
      updatedMeeting.toMap(),
      where: 'id = ?',
      whereArgs: [meeting.id],
    );
  }

  /// Delete a meeting by ID
  Future<int> deleteMeeting(String id) async {
    final db = await instance.database;

    return await db.delete(
      'meetings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check for conflicting meetings
  /// Returns list of meetings that conflict with the given time slot
  Future<List<Meeting>> getConflictingMeetings(
    DateTime startTime,
    int durationMinutes, {
    String? excludeMeetingId,
  }) async {
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    // Get all meetings that could potentially conflict
    final allMeetings = await getMeetingsInRange(
      startTime.subtract(const Duration(days: 1)),
      endTime.add(const Duration(days: 1)),
    );

    // Filter for actual conflicts
    final conflicts = allMeetings.where((meeting) {
      // Exclude the meeting being edited
      if (excludeMeetingId != null && meeting.id == excludeMeetingId) {
        return false;
      }

      // Check if meetings overlap
      final meetingEnd = meeting.endTime;
      return (startTime.isBefore(meetingEnd) &&
          endTime.isAfter(meeting.dateTime));
    }).toList();

    return conflicts;
  }

  /// Delete all meetings (useful for testing or reset)
  Future<int> deleteAllMeetings() async {
    final db = await instance.database;
    return await db.delete('meetings');
  }

  /// Get count of total meetings
  Future<int> getMeetingsCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM meetings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
