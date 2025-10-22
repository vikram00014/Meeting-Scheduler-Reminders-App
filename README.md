# Meeting Scheduler & Reminders App 📅🤖

A powerful cross-platform Flutter mobile application for scheduling meetings with AI-powered natural language processing using Google Gemini API. Perfect for students and professionals who need to manage their meeting schedules efficiently.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

- 🤖 **AI-Powered Scheduling**: Natural language meeting creation using Google Gemini API
- 📅 **Interactive Calendar**: Day, week, and month views with table_calendar
- 🔔 **Smart Notifications**: Customizable reminders (1 hour, 15 minutes, 1 day before)
- 💾 **Offline-First**: Local database with sqflite for offline access
- ⚠️ **Conflict Detection**: Automatic detection of overlapping meetings
- 🎨 **Material Design 3**: Modern, beautiful UI with color-coded categories
- 📱 **Cross-Platform**: Works on both iOS and Android
- 🔄 **Real-time Sync**: Provider-based state management

## 📸 Screenshots

### Calendar View
The calendar screen displays all your meetings in an organized monthly/weekly view with color coding:
- 🔵 **Blue**: Work meetings
- 🟢 **Green**: Personal meetings
- 🟠 **Orange**: Other meetings

### AI Chat Assistant
Chat with the AI to schedule meetings naturally:
- "Schedule team meeting tomorrow at 3 PM"
- "Meeting with Sarah next Monday at 10 AM for 2 hours"
- "Lunch with mom on Friday at 12:30"

### Meeting Details
View comprehensive meeting information including participants, duration, reminders, and descriptions.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Google Gemini API key

### Installation

1. **Clone or download this project**
   ```bash
   cd meeting_scheduler
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Get your Google Gemini API key**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Create API Key"
   - Copy the generated API key

4. **Configure environment variables**
   - Rename `.env.example` to `.env`
   - Open `.env` file and replace `your_api_key_here` with your actual API key:
     ```env
     GEMINI_API_KEY=AIzaSyD_your_actual_api_key_here
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform-Specific Setup

### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    
    <application
        android:label="Meeting Scheduler"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Existing activity configuration -->
        
        <!-- Add these receivers for notifications -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

**Minimum SDK Version**: Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Or higher
        targetSdkVersion 34
    }
}
```

### iOS

Add the following to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 🏗️ Project Structure

```
lib/
├── models/                 # Data models
│   ├── meeting.dart       # Meeting model with serialization
│   └── chat_message.dart  # Chat message model
├── services/              # Business logic services
│   ├── database_service.dart      # SQLite database operations
│   ├── gemini_service.dart        # Gemini API integration
│   └── notification_service.dart  # Local notifications
├── providers/             # State management
│   ├── meeting_provider.dart  # Meeting state management
│   └── chat_provider.dart     # Chat state management
├── screens/               # UI screens
│   ├── calendar_screen.dart          # Calendar view
│   ├── chat_screen.dart              # AI chat interface
│   ├── meeting_details_screen.dart   # Meeting details
│   ├── add_edit_meeting_screen.dart  # Create/edit meetings
│   └── settings_screen.dart          # App settings
├── widgets/               # Reusable widgets
│   ├── meeting_card.dart  # Meeting display card
│   └── chat_bubble.dart   # Chat message bubble
└── main.dart              # App entry point
```

## 💡 Usage Examples

### Natural Language Commands

The AI assistant understands various formats:

**Basic Scheduling:**
```
"Schedule team meeting tomorrow at 3 PM"
"Meeting with John on Friday at 2 PM"
"Lunch on Monday at noon"
```

**With Duration:**
```
"Project review next Tuesday at 10 AM for 2 hours"
"30-minute standup tomorrow at 9 AM"
```

**With Participants:**
```
"Meeting with Sarah and Mike on Wednesday at 3 PM"
"Conference call with clients tomorrow at 4 PM"
```

**Category Detection:**
The AI automatically categorizes meetings:
- **Work**: team meeting, standup, project review, conference call
- **Personal**: lunch with friends, dinner with family, coffee with mom
- **Other**: general events

### Manual Meeting Creation

1. Tap the **+** button on the calendar screen
2. Fill in meeting details:
   - Title (required)
   - Date and time
   - Duration
   - Category (Work/Personal/Other)
   - Description
   - Participants
3. Configure reminders (15 min, 1 hour, 1 day before)
4. Tap "Create Meeting"

### Managing Meetings

**Edit Meeting:**
- Swipe right on a meeting card, or
- Tap the meeting and use the edit option

**Delete Meeting:**
- Swipe left on a meeting card
- Confirm deletion

**View Details:**
- Tap on any meeting card to view full details

## 🔧 Configuration

### Reminder Settings

Default reminders are set to:
- 1 hour before the meeting
- 15 minutes before the meeting

You can customize these when creating or editing meetings.

### Notification Channels (Android)

The app uses the following notification channel:
- **Channel ID**: `meeting_reminders`
- **Channel Name**: Meeting Reminders
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled

## 🌐 API Integration

### Gemini API Endpoint
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
```

### Request Format
```json
{
  "contents": [{
    "parts": [
      {"text": "system_prompt"},
      {"text": "user_request"}
    ]
  }],
  "generationConfig": {
    "temperature": 0.2,
    "topK": 20,
    "topP": 0.8,
    "maxOutputTokens": 1024
  }
}
```

### Response Format
```json
{
  "success": true,
  "data": {
    "title": "Team Meeting",
    "date": "2025-10-23",
    "time": "15:00",
    "duration": 60,
    "description": "Discuss project progress",
    "participants": ["John", "Sarah"],
    "category": "work"
  }
}
```

### Error Handling

The app handles:
- ✅ Network failures (offline mode)
- ✅ API rate limits (retry with exponential backoff)
- ✅ Invalid responses (user-friendly error messages)
- ✅ Timeout errors (30-second timeout)

## 🎨 UI Customization

### Theme
The app uses Material Design 3 with:
- **Primary Color**: Blue
- **System Theme Support**: Light/Dark mode
- **Card Elevation**: 2
- **Border Radius**: 12px

### Color Coding
- 🔵 **Work meetings**: Blue (#2196F3)
- 🟢 **Personal meetings**: Green (#4CAF50)
- 🟠 **Other meetings**: Orange (#FF9800)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  table_calendar: ^3.0.9              # Calendar widget
  flutter_local_notifications: ^16.3.0 # Local notifications
  timezone: ^0.9.2                    # Timezone support
  sqflite: ^2.3.0                     # SQLite database
  path: ^1.8.3                        # Path utilities
  http: ^1.1.0                        # HTTP client
  flutter_dotenv: ^5.1.0              # Environment variables
  provider: ^6.1.1                    # State management
  intl: ^0.19.0                       # Date formatting
  uuid: ^4.2.2                        # Unique IDs
```

## 🔒 Security

- ✅ API keys stored securely in `.env` file (not committed to version control)
- ✅ Local data encrypted by device OS
- ✅ No cloud synchronization (all data stays on device)
- ✅ HTTPS for all API calls

## 🐛 Troubleshooting

### Notifications not working

**Android:**
1. Check app permissions in device settings
2. Ensure "Do Not Disturb" is off
3. Verify notification channel is enabled

**iOS:**
1. Check notification permissions in Settings > Notifications
2. Ensure app has permission to send notifications

### API errors

1. Verify your API key in `.env` file
2. Check internet connection
3. Ensure API key hasn't exceeded rate limits
4. Visit [Google AI Studio](https://makersuite.google.com) to check quota

### Database errors

1. Clear app data and reinstall
2. Use "Clear All Data" in Settings
3. Check device storage space

## 📝 Architecture

### Offline-First Design
- All meetings stored locally in SQLite
- App works fully offline for viewing and managing existing meetings
- AI features require internet connection
- Notifications work offline once scheduled

### State Management
- **Provider pattern** for reactive state management
- `MeetingProvider`: Manages meeting CRUD operations
- `ChatProvider`: Manages AI chat interactions

### Database Schema
```sql
CREATE TABLE meetings (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  dateTime TEXT NOT NULL,
  durationMinutes INTEGER NOT NULL,
  description TEXT,
  participants TEXT NOT NULL,
  category TEXT NOT NULL,
  reminderEnabled INTEGER NOT NULL,
  reminderMinutesBefore TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT
);

CREATE INDEX idx_meetings_datetime ON meetings(dateTime);
```

## 🤝 Contributing

Contributions are welcome! This is a learning project, so feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is created for educational purposes. Feel free to use and modify as needed.

## 🙏 Acknowledgments

- **Google Gemini AI**: For the powerful natural language processing API
- **Flutter Team**: For the amazing framework
- **Open Source Community**: For the excellent packages used in this project

## 📞 Support

For issues or questions:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review the code comments (heavily documented)
3. Check the Settings screen for help information

## 🎯 Future Enhancements

Potential features for future versions:
- [ ] Cloud sync across devices
- [ ] Calendar integration (Google Calendar, etc.)
- [ ] Voice input for AI assistant
- [ ] Meeting templates
- [ ] Export meetings to PDF/CSV
- [ ] Recurring meetings support
- [ ] Video call integration
- [ ] Team collaboration features

---

**Built with ❤️ using Flutter and Google Gemini AI**

Happy Scheduling! 📅✨
