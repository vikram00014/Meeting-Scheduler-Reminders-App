import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../providers/meeting_provider.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Notifications Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notification_add, color: Colors.blue),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            onTap: () {
              NotificationService.instance.showImmediateNotification(
                title: 'Test Notification',
                body: 'This is a test notification from Meeting Scheduler',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test notification sent!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const Divider(),
          // Data Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Consumer<MeetingProvider>(
            builder: (context, provider, child) {
              return ListTile(
                leading: const Icon(Icons.event_note, color: Colors.purple),
                title: const Text('Total Meetings'),
                subtitle: Text('${provider.meetings.length} meeting(s) stored'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text(
              'Clear All Meetings',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all meetings permanently'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Meetings?'),
                  content: const Text(
                    'Are you sure you want to delete all meetings? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Clear all meetings
                        final provider = context.read<MeetingProvider>();
                        for (final meeting in provider.meetings) {
                          await provider.deleteMeeting(meeting.id);
                        }

                        // Cancel all notifications
                        await NotificationService.instance
                            .cancelAllNotifications();

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All meetings deleted'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // App Info Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.event_available, color: Colors.green),
            title: const Text('About App'),
            subtitle: const Text('AI-Powered Meeting Scheduler'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Meeting Scheduler',
                applicationVersion: '1.0.0',
                applicationIcon:
                    const Icon(Icons.event, size: 48, color: Colors.blue),
                children: const [
                  Text(
                    'A smart meeting scheduling app powered by Google Gemini AI.\n\n'
                    'Features:\n'
                    '• AI-powered natural language scheduling\n'
                    '• Interactive calendar with analytics\n'
                    '• Smart notifications & reminders\n'
                    '• Meeting link generator\n'
                    '• Share invitations easily\n'
                    '• Offline-first architecture',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
