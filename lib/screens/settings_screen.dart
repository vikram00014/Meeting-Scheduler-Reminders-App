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
          const SizedBox(height: 16),
          // App Info Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'App Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('About'),
            subtitle: const Text('Meeting Scheduler with AI Assistant'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Meeting Scheduler',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.event, size: 48),
                children: const [
                  Text(
                    'A smart meeting scheduling app powered by Google Gemini AI.\n\n'
                    'Features:\n'
                    '• AI-powered natural language scheduling\n'
                    '• Interactive calendar views\n'
                    '• Smart conflict detection\n'
                    '• Local notifications\n'
                    '• Offline-first architecture',
                  ),
                ],
              );
            },
          ),
          const Divider(),
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
          FutureBuilder<bool>(
            future: NotificationService.instance.areNotificationsEnabled(),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return ListTile(
                leading: Icon(
                  enabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
                title: const Text('Notifications Status'),
                subtitle: Text(enabled ? 'Enabled' : 'Disabled'),
                trailing: enabled
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pending),
            title: const Text('Pending Notifications'),
            onTap: () async {
              final pending =
                  await NotificationService.instance.getPendingNotifications();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pending Notifications'),
                    content: Text(
                      pending.isEmpty
                          ? 'No pending notifications'
                          : '${pending.length} notification(s) scheduled',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notification_add),
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
                leading: const Icon(Icons.event_note),
                title: const Text('Total Meetings'),
                subtitle: Text('${provider.meetings.length} meeting(s) stored'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Data'),
            subtitle: const Text('Reload all meetings from database'),
            onTap: () async {
              await context.read<MeetingProvider>().loadMeetings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data refreshed successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Delete all meetings and notifications'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text(
                    'Are you sure you want to delete all meetings? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
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
                              content: Text('All data cleared'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // Help Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Help & Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('How to Use'),
            subtitle: const Text('Learn how to use the AI assistant'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use AI Assistant'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'The AI Assistant can understand natural language requests to schedule meetings.\n\n'
                      'Example commands:\n\n'
                      '• "Schedule team meeting tomorrow at 3 PM"\n'
                      '• "Meeting with Sarah next Monday at 10 AM for 2 hours"\n'
                      '• "Lunch with mom on Friday at 12:30"\n'
                      '• "Project review on Dec 25 at 2 PM"\n\n'
                      'The AI will extract the meeting details and ask for confirmation before creating the meeting.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('API Configuration'),
            subtitle: const Text('Setup Gemini API key'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('API Configuration'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'To use the AI assistant, you need a Google Gemini API key.\n\n'
                      'Steps to obtain an API key:\n\n'
                      '1. Visit https://makersuite.google.com/app/apikey\n'
                      '2. Sign in with your Google account\n'
                      '3. Create a new API key\n'
                      '4. Copy the API key\n'
                      '5. Add it to the .env file in the project root:\n'
                      '   GEMINI_API_KEY=your_api_key_here\n\n'
                      'The API is free to use with rate limits.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
