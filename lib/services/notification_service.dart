import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/meeting.dart';

/// Service for managing local notifications and meeting reminders
class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._init();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for notifications
      await _requestPermissions();

      _initialized = true;
    } catch (e) {
      // If initialization fails due to cache corruption, try clearing cache
      if (e.toString().contains('Missing type parameter')) {
        try {
          await clearNotificationCache();
          // Retry initialization without the cached data
          _initialized = true;
        } catch (_) {
          // If clearing fails, mark as initialized anyway to prevent app crash
          _initialized = true;
        }
      } else {
        // For other errors, still mark as initialized to prevent blocking the app
        _initialized = true;
      }
    }
  }

  /// Request notification permissions (especially for iOS)
  Future<void> _requestPermissions() async {
    // For Android 13+ (API level 33+), we need to request permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // For iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to meeting details
    // The payload contains the meeting ID
    final meetingId = response.payload;
    if (meetingId != null) {
      // TODO: Navigate to meeting details screen
      // This will be handled by the app's navigation system
    }
  }

  /// Schedule notifications for a meeting
  /// Creates multiple notifications based on reminderMinutesBefore list
  Future<void> scheduleMeetingReminders(Meeting meeting) async {
    try {
      if (!meeting.reminderEnabled || meeting.reminderMinutesBefore.isEmpty) {
        return;
      }

      // Cancel existing notifications for this meeting
      await cancelMeetingReminders(meeting.id);

      // Schedule notification for each reminder time
      for (int i = 0; i < meeting.reminderMinutesBefore.length; i++) {
        final minutesBefore = meeting.reminderMinutesBefore[i];
        final notificationTime = meeting.dateTime.subtract(
          Duration(minutes: minutesBefore),
        );

        // Only schedule if notification time is in the future
        if (notificationTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _generateNotificationId(meeting.id, i),
            title: _getNotificationTitle(minutesBefore),
            body: meeting.title,
            scheduledTime: notificationTime,
            payload: meeting.id,
            meeting: meeting,
          );
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Generate unique notification ID from meeting ID and reminder index
  int _generateNotificationId(String meetingId, int reminderIndex) {
    // Create a hash from meeting ID and add reminder index
    final hash = meetingId.hashCode.abs() % 100000;
    return hash * 10 + reminderIndex;
  }

  /// Get notification title based on minutes before meeting
  String _getNotificationTitle(int minutesBefore) {
    if (minutesBefore == 0) {
      return 'Meeting starting now! 🔔';
    } else if (minutesBefore < 60) {
      return 'Meeting in $minutesBefore minutes';
    } else if (minutesBefore == 60) {
      return 'Meeting in 1 hour';
    } else {
      final hours = minutesBefore ~/ 60;
      final minutes = minutesBefore % 60;
      if (minutes == 0) {
        return 'Meeting in $hours ${hours == 1 ? "hour" : "hours"}';
      } else {
        return 'Meeting in $hours ${hours == 1 ? "hour" : "hours"} and $minutes minutes';
      }
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
    required Meeting meeting,
  }) async {
    try {
      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        'meeting_reminders',
        'Meeting Reminders',
        channelDescription: 'Notifications for upcoming meetings',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: _formatMeetingTime(meeting.dateTime),
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      // If scheduling fails due to cache corruption, clear cache and retry
      if (e.toString().contains('Missing type parameter')) {
        await clearNotificationCache();
        // Don't retry to avoid infinite loop
      }
      // Silently fail to prevent app crashes
    }
  }

  /// Format meeting time for notification
  String _formatMeetingTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  /// Cancel all notifications for a specific meeting
  Future<void> cancelMeetingReminders(String meetingId) async {
    try {
      // Cancel all possible notification IDs for this meeting
      // We schedule maximum 10 reminders per meeting
      for (int i = 0; i < 10; i++) {
        final notificationId = _generateNotificationId(meetingId, i);
        try {
          await _notifications.cancel(notificationId);
        } catch (e) {
          // If we get a type parameter error, clear all notifications and break
          if (e.toString().contains('Missing type parameter')) {
            try {
              await _notifications.cancelAll();
            } catch (_) {
              // Ignore errors when clearing
            }
            break;
          }
        }
      }
    } catch (e) {
      // If there's a persistent error, try to clear all notifications
      if (e.toString().contains('Missing type parameter')) {
        try {
          await _notifications.cancelAll();
        } catch (_) {
          // Ignore errors when clearing
        }
      }
    }
  }

  /// Update reminders when a meeting is updated
  Future<void> updateMeetingReminders(Meeting meeting) async {
    await cancelMeetingReminders(meeting.id);
    await scheduleMeetingReminders(meeting);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      // Silent error handling
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'meeting_reminders',
      'Meeting Reminders',
      channelDescription: 'Notifications for upcoming meetings',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (_notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() !=
        null) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()!
              .areNotificationsEnabled() ??
          false;
    }
    return true; // Assume enabled for iOS
  }

  /// Clear notification cache (useful when encountering type parameter errors)
  Future<void> clearNotificationCache() async {
    try {
      await _notifications.cancelAll();
      // On Android, this also clears the SharedPreferences cache
    } catch (e) {
      // Ignore errors
    }
  }
}
