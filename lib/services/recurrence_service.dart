import '../models/meeting.dart';
import 'package:uuid/uuid.dart';

/// Service for handling recurring meeting logic
class RecurrenceService {
  static const uuid = Uuid();

  /// Generate recurring meeting instances
  static List<Meeting> generateRecurringMeetings({
    required Meeting baseMeeting,
    required String recurrenceRule,
    required DateTime until,
    int? interval,
  }) {
    final meetings = <Meeting>[];
    final groupId = baseMeeting.recurrenceGroupId ?? uuid.v4();
    var currentDate = baseMeeting.dateTime;
    interval ??= 1;

    while (currentDate.isBefore(until) || currentDate.isAtSameMomentAs(until)) {
      // Create meeting instance
      final meeting = baseMeeting.copyWith(
        id: uuid.v4(),
        dateTime: currentDate,
        isRecurring: true,
        recurrenceRule: recurrenceRule,
        recurrenceInterval: interval,
        recurrenceEndDate: until,
        recurrenceGroupId: groupId,
        createdAt: DateTime.now(),
      );

      meetings.add(meeting);

      // Calculate next occurrence
      switch (recurrenceRule.toLowerCase()) {
        case 'daily':
          currentDate = currentDate.add(Duration(days: interval));
          break;
        case 'weekly':
          currentDate = currentDate.add(Duration(days: 7 * interval));
          break;
        case 'monthly':
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + interval,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        default:
          break;
      }
    }

    return meetings;
  }

  /// Get recurrence description text
  static String getRecurrenceDescription(Meeting meeting) {
    if (!meeting.isRecurring || meeting.recurrenceRule == null) {
      return 'Does not repeat';
    }

    final interval = meeting.recurrenceInterval ?? 1;
    final rule = meeting.recurrenceRule!.toLowerCase();

    String description;
    if (interval == 1) {
      description = 'Every ${_getRuleText(rule)}';
    } else {
      description = 'Every $interval ${_getPluralRuleText(rule)}';
    }

    if (meeting.recurrenceEndDate != null) {
      final endDate = meeting.recurrenceEndDate!;
      description += ' until ${endDate.day}/${endDate.month}/${endDate.year}';
    }

    return description;
  }

  static String _getRuleText(String rule) {
    switch (rule) {
      case 'daily':
        return 'day';
      case 'weekly':
        return 'week';
      case 'monthly':
        return 'month';
      default:
        return rule;
    }
  }

  static String _getPluralRuleText(String rule) {
    switch (rule) {
      case 'daily':
        return 'days';
      case 'weekly':
        return 'weeks';
      case 'monthly':
        return 'months';
      default:
        return '${rule}s';
    }
  }
}
