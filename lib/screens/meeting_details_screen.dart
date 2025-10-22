import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meeting.dart';

/// Screen to view meeting details
class MeetingDetailsScreen extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailsScreen({
    super.key,
    required this.meeting,
  });

  Color _getCategoryColor() {
    switch (meeting.category) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon() {
    switch (meeting.category) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          meeting.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    meeting.category.toUpperCase(),
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Date and Time
            _buildDetailSection(
              icon: Icons.calendar_today,
              title: 'Date',
              content: dateFormat.format(meeting.dateTime),
            ),
            _buildDetailSection(
              icon: Icons.access_time,
              title: 'Time',
              content:
                  '${timeFormat.format(meeting.dateTime)} - ${timeFormat.format(meeting.endTime)}',
            ),
            _buildDetailSection(
              icon: Icons.timer,
              title: 'Duration',
              content: '${meeting.durationMinutes} minutes',
            ),
            // Description
            if (meeting.description != null && meeting.description!.isNotEmpty)
              _buildDetailSection(
                icon: Icons.description,
                title: 'Description',
                content: meeting.description!,
              ),
            // Participants
            if (meeting.participants.isNotEmpty)
              _buildDetailSection(
                icon: Icons.people,
                title: 'Participants',
                content: meeting.participants.join('\n'),
              ),
            // Reminders
            if (meeting.reminderEnabled)
              _buildDetailSection(
                icon: Icons.notifications_active,
                title: 'Reminders',
                content: meeting.reminderMinutesBefore
                    .map((minutes) => _formatReminderTime(minutes))
                    .join('\n'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatReminderTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes before';
    } else if (minutes == 60) {
      return '1 hour before';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? "hour" : "hours"} before';
      } else {
        return '$hours ${hours == 1 ? "hour" : "hours"} and $mins minutes before';
      }
    }
  }
}
