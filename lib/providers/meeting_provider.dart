import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// Provider for managing meeting state and operations
class MeetingProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;

  List<Meeting> _meetings = [];
  bool _isLoading = false;
  String? _error;

  List<Meeting> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get meetings for a specific date
  List<Meeting> getMeetingsForDate(DateTime date) {
    return _meetings.where((meeting) {
      final meetingDate = meeting.dateTime;
      return meetingDate.year == date.year &&
          meetingDate.month == date.month &&
          meetingDate.day == date.day;
    }).toList();
  }

  /// Get upcoming meetings
  List<Meeting> getUpcomingMeetings() {
    final now = DateTime.now();
    return _meetings.where((meeting) => meeting.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Load all meetings from database
  Future<void> loadMeetings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _meetings = await _db.getAllMeetings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new meeting
  Future<bool> addMeeting(Meeting meeting) async {
    try {
      _error = null;

      // Check for conflicts
      final conflicts = await _db.getConflictingMeetings(
        meeting.dateTime,
        meeting.durationMinutes,
      );

      if (conflicts.isNotEmpty) {
        _error = 'This meeting conflicts with: ${conflicts.first.title}';
        notifyListeners();
        return false;
      }

      // Add to database
      await _db.createMeeting(meeting);

      // Schedule notifications
      await _notifications.scheduleMeetingReminders(meeting);

      // Reload meetings
      await loadMeetings();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing meeting
  Future<bool> updateMeeting(Meeting meeting) async {
    try {
      _error = null;

      // Check for conflicts (excluding this meeting)
      final conflicts = await _db.getConflictingMeetings(
        meeting.dateTime,
        meeting.durationMinutes,
        excludeMeetingId: meeting.id,
      );

      if (conflicts.isNotEmpty) {
        _error = 'This meeting conflicts with: ${conflicts.first.title}';
        notifyListeners();
        return false;
      }

      // Update in database
      await _db.updateMeeting(meeting);

      // Update notifications
      await _notifications.updateMeetingReminders(meeting);

      // Reload meetings
      await loadMeetings();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a meeting
  Future<bool> deleteMeeting(String meetingId) async {
    try {
      _error = null;

      // Cancel notifications
      await _notifications.cancelMeetingReminders(meetingId);

      // Delete from database
      await _db.deleteMeeting(meetingId);

      // Reload meetings
      await loadMeetings();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get a specific meeting by ID
  Future<Meeting?> getMeeting(String id) async {
    try {
      return await _db.getMeeting(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get meetings in a date range
  Future<List<Meeting>> getMeetingsInRange(DateTime start, DateTime end) async {
    try {
      return await _db.getMeetingsInRange(start, end);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Check if a time slot has conflicts
  Future<List<Meeting>> checkConflicts(
    DateTime dateTime,
    int durationMinutes, {
    String? excludeMeetingId,
  }) async {
    try {
      return await _db.getConflictingMeetings(
        dateTime,
        durationMinutes,
        excludeMeetingId: excludeMeetingId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}
