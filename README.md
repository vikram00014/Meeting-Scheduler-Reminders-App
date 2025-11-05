# Meeting Scheduler & Reminders App 📅🤖

A powerful cross-platform Flutter mobile application for intelligent meeting scheduling with AI-powered natural language processing using Google Gemini API. Complete with analytics dashboard, meeting link generator, and smart notifications. Perfect for students, professionals, and teams managing their schedules efficiently.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)

## ✨ Key Features

### 🤖 AI-Powered Scheduling
- **Natural Language Processing**: Create meetings using everyday language with Google Gemini AI
- **Smart Participant Detection**: Automatically extracts names, emails, and phone numbers
- **Intelligent Notifications**: AI asks if you want to notify participants automatically
- **Context Awareness**: Understands dates, times, durations, and meeting categories

### 📊 Analytics Dashboard
- **Meeting Statistics**: Track total meetings, hours spent, and average duration
- **Time Analysis**: View upcoming vs completed meetings
- **Category Breakdown**: Visual charts for work, personal, and other meetings
- **Top Participants**: See who you meet with most frequently
- **Peak Hours Chart**: Identify your busiest meeting times
- **Flexible Filters**: View data by This Week, This Month, or All Time

### 🔗 Meeting Link Generator
- **Quick Link Creation**: Generate Zoom, Google Meet, and Microsoft Teams links instantly
- **One-Tap Join**: Click to open meeting links directly
- **Copy to Clipboard**: Easy sharing of meeting URLs
- **Link Display**: Prominent meeting link in details view

### 📅 Interactive Calendar
- **Multiple Views**: Day, week, month, and 2-week views
- **Color Coding**: Visual distinction between work, personal, and other meetings
- **Conflict Detection**: Automatic detection of overlapping meetings
- **Quick Navigation**: Jump to today with one tap
- **Analytics Access**: Direct link to analytics dashboard

### 🔔 Smart Notifications & Reminders
- **Customizable Reminders**: Set multiple reminders (At start, 15 min, 1 hour, 1 day before)
- **Meeting Start Alert**: Get notified exactly when meeting begins
- **Persistent Notifications**: Reminders survive app restarts
- **Test Notifications**: Verify notification settings work correctly
- **Notification Management**: View and manage all scheduled notifications

### 📤 Share Meeting Invitations
- **Multi-Platform Sharing**: Share via Email, SMS, WhatsApp, or any installed app
- **Formatted Invitations**: Professional meeting invitations with all details
- **Participant Notifications**: Notify attendees directly from the app
- **Contact Integration**: Add participant emails and phone numbers

### 💾 Offline-First Architecture
- **Local Database**: SQLite database stores all meetings locally
- **Past Meeting History**: All meetings (past and future) stored for analytics
- **No Internet Required**: Full functionality without internet (except AI chat)
- **Fast Performance**: Instant loading and searching

### 🎨 Modern UI/UX
- **Material Design 3**: Clean, modern interface with Material You
- **Dark Mode Support**: Automatic theme switching based on system preference
- **Professional Colors**: Polished blue color scheme with proper contrast
- **Smooth Animations**: Fluid transitions and interactions
- **Responsive Design**: Works beautifully on all screen sizes

## 📸 Screenshots

### 🏠 Main Screens
- **Calendar View**: Interactive calendar with all your meetings, color-coded by category
- **AI Chat**: Natural language interface for scheduling meetings
- **Analytics Dashboard**: Comprehensive statistics and insights
- **Settings**: Simple, clean settings with essential options

### 🎨 Color Coding
- 🔵 **Blue**: Work meetings
- 🟢 **Green**: Personal meetings
- 🟠 **Orange**: Other meetings

### 💬 AI Chat Examples
```
✅ "Schedule team meeting tomorrow at 3 PM"
✅ "Meeting with Sarah at sarah@email.com next Monday at 10 AM"
✅ "Lunch with mom on Friday at 12:30 and notify her"
✅ "Project review at 2 PM, send invite to john@company.com"
✅ "Daily standup every day at 9 AM for 15 minutes"
```

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
│   ├── meeting.dart       # Meeting model with meetingLink field
│   └── chat_message.dart  # Chat message model
├── services/              # Business logic services
│   ├── database_service.dart      # SQLite database (version 2)
│   ├── gemini_service.dart        # Gemini API integration
│   ├── notification_service.dart  # Local notifications with error handling
│   ├── share_service.dart         # Meeting invitation sharing
│   └── analytics_service.dart     # Meeting analytics calculations
├── providers/             # State management
│   ├── meeting_provider.dart  # Meeting state management
│   └── chat_provider.dart     # Chat state management with sharing
├── screens/               # UI screens
│   ├── calendar_screen.dart            # Calendar with analytics access
│   ├── chat_screen.dart                # AI chat with notification prompts
│   ├── meeting_details_screen.dart     # Details with link display
│   ├── add_edit_meeting_screen.dart    # Create/edit with link generator
│   ├── analytics_dashboard_screen.dart # Analytics with charts
│   └── settings_screen.dart            # Simplified settings
├── widgets/               # Reusable widgets
│   ├── meeting_card.dart  # Meeting display card
│   └── chat_bubble.dart   # Chat message bubble
└── main.dart              # App entry with Material Design 3 theme
```

## 💡 Usage Examples

### 🤖 Natural Language Commands

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

**With Notification:**
```
"Meeting with john@company.com tomorrow at 2 PM and notify him"
"Lunch with Sarah (555-1234) on Friday and send invite"
"Team meeting tomorrow, email everyone at team@company.com"
```

**Category Detection:**
The AI automatically categorizes meetings:
- **Work**: team meeting, standup, project review, conference call
- **Personal**: lunch with friends, dinner with family, coffee with mom
- **Other**: general events

### 🔗 Meeting Link Generator

**Quick Links:**
1. Open Add/Edit Meeting screen
2. Tap "Meeting Link" field
3. Choose template:
   - **Zoom**: Generates `https://zoom.us/j/xxx-xxx-xxx`
   - **Google Meet**: Generates `https://meet.google.com/xxx-xxxx-xxx`
   - **Teams**: Generates `https://teams.microsoft.com/l/meetup-join/xxx`
   - **Custom**: Enter your own link

**Using Links:**
- Tap to copy link to clipboard
- Click "Open Link" button to join meeting
- Link appears in meeting details and invitations

### 📤 Sharing Invitations

**Manual Sharing:**
1. Open meeting details
2. Tap share icon
3. Choose sharing method:
   - Email
   - SMS
   - Any installed app (WhatsApp, Slack, etc.)

**AI-Triggered Sharing:**
- Say "notify" in AI chat when scheduling
- AI detects participant contact info (email/phone)
- App prompts to share invitation automatically

**Invitation Format:**
```
Meeting Invitation: Team Review

Date: January 15, 2024
Time: 2:00 PM - 3:30 PM

Participants: John Doe, Sarah Smith
Category: Work

Description: Quarterly project review meeting

Meeting Link: https://zoom.us/j/123-456-789

Generated by Meeting Scheduler App
```

### 📊 Analytics Dashboard

**Access Analytics:**
- Tap analytics icon in calendar screen AppBar
- View comprehensive statistics

**Available Metrics:**
1. **Total Meetings**: All-time meeting count
2. **Total Hours**: Cumulative time in meetings
3. **Average Duration**: Mean meeting length
4. **Upcoming/Completed**: Current status breakdown
5. **Category Breakdown**: Visual pie chart
6. **Top Participants**: Most frequent attendees (top 5)
7. **Peak Hours**: Bar chart showing busiest times

**Filter Options:**
- This Week
- This Month
- All Time

### ✏️ Manual Meeting Creation

1. Tap the **+** button on the calendar screen
2. Fill in meeting details:
   - Title (required)
   - Date and time
   - Duration (in minutes)
   - Category (Work/Personal/Other)
   - Description
   - Participants (comma-separated names/emails)
   - Meeting Link (optional, with quick generator)
3. Configure reminders (At start, 15 min, 1 hour, 1 day before)
4. Tap "Create Meeting"
5. (Optional) Share invitation with participants

### 📝 Managing Meetings

**Edit Meeting:**
- Swipe right on a meeting card, or
- Tap the meeting and use the edit option
- Update details and save

**Delete Meeting:**
- Swipe left on a meeting card
- Confirm deletion
- Associated notifications are automatically cancelled

**View Details:**
- Tap on any meeting card to view full details
- See participants, description, reminders, and meeting link
- Copy link or open in browser

## 🔧 Configuration & Settings

### ⚙️ Settings Screen

**Available Options:**
1. **Test Notifications**: Send test notification to verify notification permissions
2. **App Version**: Current version information

**Simplified Design**: Removed unnecessary options for cleaner UX

### 🔔 Reminder Settings

Available reminder options:
- At meeting start time (0 minutes) 🆕
- 15 minutes before the meeting
- 1 hour before the meeting
- 1 day before the meeting

You can select any combination of these when creating or editing meetings.

### 📱 Notification Channels (Android)

The app uses the following notification channel:
- **Channel ID**: `meeting_reminders`
- **Channel Name**: Meeting Reminders
- **Importance**: High
- **Sound**: Enabled
- **Vibration**: Enabled
- **Exact Alarms**: Enabled for precise timing

### 🎨 Theme Configuration

**Light Mode:**
- Primary Color: Material Blue (#2196F3)
- Clean white backgrounds
- High contrast for readability

**Dark Mode:**
- Automatic system preference detection
- Dark grey backgrounds
- Blue accent colors
- OLED-friendly design

## 🌐 API Integration

### Google Gemini API

**Endpoint:**
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent
```

**Model**: gemini-2.5-flash

**Request Format:**
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

**Response Format:**
```json
{
  "success": true,
  "data": {
    "title": "Team Meeting",
    "date": "2025-01-23",
    "time": "15:00",
    "duration": 60,
    "description": "Discuss project progress",
    "participants": ["John Doe", "Sarah Smith"],
    "category": "work",
    "participantEmails": ["john@company.com"],
    "participantPhones": ["+1234567890"],
    "notifyParticipants": true
  }
}
```

**AI Features:**
- Natural language understanding for dates/times
- Participant extraction from text
- Category classification (work/personal/other)
- Contact information detection (emails/phones)
- Intent detection for notifications

### Error Handling

The app handles:
- ✅ Network failures (offline mode)
- ✅ API rate limits (retry with exponential backoff)
- ✅ Invalid responses (user-friendly error messages)
- ✅ Timeout errors (30-second timeout)
- ✅ Notification permission issues (graceful degradation)
- ✅ Platform-specific errors (Android/iOS compatibility)

## 🎨 UI Customization

### Material Design 3 Theme

**Light Mode:**
- **Primary**: #2196F3 (Material Blue)
- **Secondary**: #03DAC6 (Teal)
- **Surface**: #FFFFFF (White)
- **Background**: #F5F5F5 (Light Grey)
- **Error**: #B00020 (Red)

**Dark Mode:**
- **Primary**: #2196F3 (Material Blue)
- **Secondary**: #03DAC6 (Teal)
- **Surface**: #1E1E1E (Dark Grey)
- **Background**: #121212 (Black)
- **Error**: #CF6679 (Light Red)

**Component Styling:**
- Card Elevation: 2
- Border Radius: 12px
- Input Border Radius: 8px
- Button Border Radius: 8px

### Color Coding System
- 🔵 **Work meetings**: Blue (#2196F3)
- 🟢 **Personal meetings**: Green (#4CAF50)
- 🟠 **Other meetings**: Orange (#FF9800)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI Components
  table_calendar: ^3.0.9              # Interactive calendar widget
  
  # Notifications & Sharing
  flutter_local_notifications: ^17.2.4 # Local push notifications
  share_plus: ^10.1.4                  # Share functionality
  url_launcher: ^6.3.1                 # Open URLs/emails/SMS
  timezone: ^0.9.2                     # Timezone support
  
  # Database & Storage
  sqflite: ^2.3.0                     # SQLite database
  path: ^1.8.3                        # Path utilities
  
  # Networking
  http: ^1.1.0                        # HTTP client for API calls
  
  # Configuration
  flutter_dotenv: ^5.1.0              # Environment variables
  
  # State Management
  provider: ^6.1.1                    # Provider pattern
  
  # Utilities
  intl: ^0.19.0                       # Date/time formatting
  uuid: ^4.2.2                        # Unique ID generation
```

**Total App Size**: ~23.1 MB (Release APK)

## 🔒 Security & Privacy

- ✅ **API Keys**: Stored securely in `.env` file (not committed to git)
- ✅ **Local Storage**: All data encrypted by device OS
- ✅ **No Cloud Sync**: All data stays on your device
- ✅ **HTTPS**: All API calls use secure HTTPS
- ✅ **Permissions**: Only requests necessary permissions
- ✅ **No Analytics**: No user tracking or data collection

## 🐛 Troubleshooting

### 🔔 Notifications not working

**Android:**
1. Open Settings > Apps > Meeting Scheduler > Notifications
2. Enable all notification categories
3. Turn off "Do Not Disturb" mode
4. Check battery optimization settings (disable for this app)
5. Use "Test Notifications" in Settings screen

**iOS:**
1. Open Settings > Notifications > Meeting Scheduler
2. Enable "Allow Notifications"
3. Choose alert style (Banner/Alert)
4. Enable sounds and badges

**Common Issues:**
- **"Missing type parameter" error**: Fixed with notification cache clearing
- **Notifications not showing**: Check exact alarm permissions (Android 12+)
- **Late notifications**: Disable battery optimization

### 🌐 API Errors

**"API key invalid":**
1. Verify `.env` file has correct API key format
2. Check for extra spaces or quotes
3. Ensure key starts with `AIzaSy...`

**"Rate limit exceeded":**
1. Wait a few minutes before trying again
2. Check your quota at [Google AI Studio](https://makersuite.google.com)
3. Consider upgrading API plan

**"Network error":**
1. Check internet connection
2. Try switching between WiFi and mobile data
3. Verify firewall isn't blocking API calls

### 💾 Database Errors

**"Database corrupted":**
1. Backup meetings (export/screenshot)
2. Clear app data in device settings
3. Reinstall app
4. Re-enter meetings

**"Migration failed":**
- App automatically handles database upgrades
- If issues persist, contact support with error logs

### 📱 Build Errors

**"Gradle build failed":**
1. Run `flutter clean`
2. Delete `android/.gradle` folder
3. Run `flutter pub get`
4. Rebuild with `flutter build apk`

**"CocoaPods error" (iOS):**
1. `cd ios && pod install`
2. Run `flutter clean`
3. Rebuild

## 🏛️ Architecture

### Offline-First Design
- **Local Database**: SQLite stores all meetings persistently
- **Full Offline Support**: View, create, edit, delete meetings without internet
- **AI Requires Internet**: Chat feature needs API connection
- **Persistent Notifications**: Scheduled notifications survive app restarts

### State Management Pattern
- **Provider Architecture**: Reactive state management
- `MeetingProvider`: Manages meeting CRUD operations and database sync
- `ChatProvider`: Manages AI chat interactions and message history

### Database Schema (Version 2)
```sql
CREATE TABLE meetings (
  id TEXT PRIMARY KEY,                 -- UUID
  title TEXT NOT NULL,                 -- Meeting title
  dateTime TEXT NOT NULL,              -- ISO 8601 format
  durationMinutes INTEGER NOT NULL,    -- Duration in minutes
  description TEXT,                    -- Optional description
  participants TEXT NOT NULL,          -- Comma-separated names
  category TEXT NOT NULL,              -- work/personal/other
  reminderEnabled INTEGER NOT NULL,    -- 0 or 1
  reminderMinutesBefore TEXT NOT NULL, -- JSON array [15, 60, 1440]
  meetingLink TEXT,                    -- NEW in v2: Zoom/Meet/Teams URL
  createdAt TEXT NOT NULL,             -- ISO 8601 timestamp
  updatedAt TEXT                       -- ISO 8601 timestamp
);

-- Indexes for performance
CREATE INDEX idx_meetings_datetime ON meetings(dateTime);
CREATE INDEX idx_meetings_category ON meetings(category);
```

**Migration Strategy:**
- Database auto-upgrades from v1 to v2
- Adds `meetingLink` column with NULL default
- Preserves all existing meeting data

### Service Layer Architecture

**GeminiService**: AI integration
- Natural language processing
- Meeting data extraction
- Participant detection
- Contact information parsing

**DatabaseService**: SQLite operations
- CRUD operations for meetings
- Database versioning and migrations
- Query optimization with indexes

**NotificationService**: Local notifications
- Schedule notifications with exact timing
- Cancel notifications on meeting deletion
- Error handling for platform issues
- Notification cache management

**ShareService**: Invitation sharing
- Format meeting invitations
- Share via email, SMS, any app
- URL launching for mailto:/sms: links

**AnalyticsService**: Meeting statistics
- Calculate meeting metrics
- Category breakdown
- Participant analysis
- Time-based filtering

## 🚀 Building for Production

### Android APK
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

**APK Size**: ~23.1 MB

**Minimum Requirements:**
- Android 5.0 (API 21) or higher
- 50 MB storage space

### iOS App
```bash
# Build release IPA
flutter build ios --release

# Archive in Xcode for App Store
```

**iOS Requirements:**
- iOS 12.0 or higher
- Xcode 14.0+

## 🤝 Contributing

Contributions are welcome! This is an educational project, so feel free to:

1. **Report Bugs**: Open an issue with details and screenshots
2. **Suggest Features**: Describe the feature and use case
3. **Submit Pull Requests**: Fork, create branch, make changes, submit PR
4. **Improve Documentation**: Fix typos, add examples, clarify instructions

**Development Setup:**
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📄 License

This project is created for educational purposes. Feel free to use and modify as needed.

**MIT License** - See LICENSE file for details

---

## 📞 Support

For issues, questions, or suggestions:
- Open a GitHub issue
- Contact: [Your contact information]

## 🙏 Acknowledgments

- **Google Gemini AI** for natural language processing
- **Flutter Team** for the amazing framework
- **Open Source Community** for excellent packages
- **Material Design** for UI/UX guidelines

---

**Made with ❤️ using Flutter**

*Last Updated: January 2025*

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
