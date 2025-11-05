import '../models/meeting.dart';

/// Service for calculating meeting analytics and statistics
class AnalyticsService {
  /// Get total meetings count
  static int getTotalMeetings(List<Meeting> meetings) {
    return meetings.length;
  }

  /// Get meetings count for a date range
  static int getMeetingsInRange(
    List<Meeting> meetings,
    DateTime start,
    DateTime end,
  ) {
    return meetings.where((m) {
      return m.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          m.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).length;
  }

  /// Get total time spent in meetings (in hours)
  static double getTotalTimeSpent(List<Meeting> meetings) {
    final totalMinutes = meetings.fold<int>(
      0,
      (sum, meeting) => sum + meeting.durationMinutes,
    );
    return totalMinutes / 60.0;
  }

  /// Get time spent in meetings for a date range (in hours)
  static double getTimeSpentInRange(
    List<Meeting> meetings,
    DateTime start,
    DateTime end,
  ) {
    final filteredMeetings = meetings.where((m) {
      return m.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          m.dateTime.isBefore(end.add(const Duration(days: 1)));
    });

    final totalMinutes = filteredMeetings.fold<int>(
      0,
      (sum, meeting) => sum + meeting.durationMinutes,
    );
    return totalMinutes / 60.0;
  }

  /// Get category breakdown (work, personal, other)
  static Map<String, int> getCategoryBreakdown(List<Meeting> meetings) {
    final breakdown = <String, int>{
      'work': 0,
      'personal': 0,
      'other': 0,
    };

    for (var meeting in meetings) {
      breakdown[meeting.category] = (breakdown[meeting.category] ?? 0) + 1;
    }

    return breakdown;
  }

  /// Get category breakdown for date range
  static Map<String, int> getCategoryBreakdownInRange(
    List<Meeting> meetings,
    DateTime start,
    DateTime end,
  ) {
    final filteredMeetings = meetings.where((m) {
      return m.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          m.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    return getCategoryBreakdown(filteredMeetings);
  }

  /// Get most frequent participants
  static List<MapEntry<String, int>> getTopParticipants(
    List<Meeting> meetings, {
    int limit = 5,
  }) {
    final participantCount = <String, int>{};

    for (var meeting in meetings) {
      for (var participant in meeting.participants) {
        if (participant.isNotEmpty) {
          participantCount[participant] =
              (participantCount[participant] ?? 0) + 1;
        }
      }
    }

    final sorted = participantCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }

  /// Get peak meeting hours (distribution across 24 hours)
  static Map<int, int> getPeakMeetingHours(List<Meeting> meetings) {
    final hourDistribution = <int, int>{};

    for (var meeting in meetings) {
      final hour = meeting.dateTime.hour;
      hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1;
    }

    return hourDistribution;
  }

  /// Get average meeting duration (in minutes)
  static double getAverageDuration(List<Meeting> meetings) {
    if (meetings.isEmpty) return 0;

    final totalMinutes = meetings.fold<int>(
      0,
      (sum, meeting) => sum + meeting.durationMinutes,
    );

    return totalMinutes / meetings.length;
  }

  /// Get upcoming meetings count
  static int getUpcomingMeetingsCount(List<Meeting> meetings) {
    final now = DateTime.now();
    return meetings.where((m) => m.dateTime.isAfter(now)).length;
  }

  /// Get past meetings count
  static int getPastMeetingsCount(List<Meeting> meetings) {
    final now = DateTime.now();
    return meetings.where((m) => m.dateTime.isBefore(now)).length;
  }

  /// Get meetings this week
  static List<Meeting> getMeetingsThisWeek(List<Meeting> meetings) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return meetings.where((m) {
      return m.dateTime
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          m.dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get meetings this month
  static List<Meeting> getMeetingsThisMonth(List<Meeting> meetings) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return meetings.where((m) {
      return m.dateTime
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          m.dateTime.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get busiest day of week (0 = Monday, 6 = Sunday)
  static int getBusiestDayOfWeek(List<Meeting> meetings) {
    final dayCount = <int, int>{};

    for (var meeting in meetings) {
      final day = meeting.dateTime.weekday;
      dayCount[day] = (dayCount[day] ?? 0) + 1;
    }

    if (dayCount.isEmpty) return 1; // Default to Monday

    return dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get day name from weekday number
  static String getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
