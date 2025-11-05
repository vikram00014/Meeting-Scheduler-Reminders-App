import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/meeting.dart';
import '../services/gemini_service.dart';
import 'package:uuid/uuid.dart';

/// Provider for managing AI chat interactions
class ChatProvider with ChangeNotifier {
  final GeminiService _gemini = GeminiService.instance;
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String? _error;
  Map<String, dynamic>? _pendingMeetingData;

  List<ChatMessage> get messages => _messages;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  Map<String, dynamic>? get pendingMeetingData => _pendingMeetingData;

  /// Send a message to the AI assistant
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Process with AI
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _gemini.parseMeetingRequest(message);

      if (response['success'] == true) {
        // Successfully extracted meeting data
        _pendingMeetingData = response['data'] as Map<String, dynamic>;

        final aiMessage = ChatMessage(
          id: const Uuid().v4(),
          message: _formatMeetingConfirmation(response['data']),
          isUser: false,
          timestamp: DateTime.now(),
          structuredData: response['data'],
        );
        _messages.add(aiMessage);
      } else if (response['question'] != null) {
        // AI needs clarification
        final aiMessage = ChatMessage(
          id: const Uuid().v4(),
          message: response['question'] as String,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      } else if (response['error'] != null) {
        // Error occurred
        _error = response['error'] as String;
        final aiMessage = ChatMessage(
          id: const Uuid().v4(),
          message: 'Sorry, I encountered an error: ${response['error']}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      }
    } catch (e) {
      _error = e.toString();
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        message: 'Sorry, something went wrong: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Format meeting data into a confirmation message
  String _formatMeetingConfirmation(Map<String, dynamic> data) {
    final title = data['title'] as String;
    final date = data['date'] as String;
    final time = data['time'] as String;
    final duration = data['duration'] as int;
    final description = data['description'] as String?;
    final participants = data['participants'] as List<dynamic>?;
    final notifyParticipants = data['notifyParticipants'] as bool? ?? false;

    final buffer = StringBuffer();
    buffer.writeln('I\'ve prepared your meeting:');
    buffer.writeln('\n📋 Title: $title');
    buffer.writeln('📅 Date: $date');
    buffer.writeln('🕒 Time: $time');
    buffer.writeln('⏱️ Duration: $duration minutes');

    if (description != null && description.isNotEmpty) {
      buffer.writeln('📝 Description: $description');
    }

    if (participants != null && participants.isNotEmpty) {
      buffer.writeln('👥 Participants: ${participants.join(", ")}');
    }

    if (notifyParticipants && participants != null && participants.isNotEmpty) {
      buffer.writeln(
          '\n📧 Participants will be notified after creating the meeting');
    }

    buffer.writeln('\nWould you like me to create this meeting?');

    return buffer.toString();
  }

  /// Create a Meeting object from pending data
  Meeting? createMeetingFromPendingData() {
    if (_pendingMeetingData == null) return null;

    try {
      final data = _pendingMeetingData!;
      final dateStr = data['date'] as String;
      final timeStr = data['time'] as String;

      // Parse date and time
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');

      final dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final meeting = Meeting(
        id: const Uuid().v4(),
        title: data['title'] as String,
        dateTime: dateTime,
        durationMinutes: data['duration'] as int? ?? 60,
        description: data['description'] as String?,
        participants: data['participants'] != null
            ? List<String>.from(data['participants'] as List)
            : [],
        category: data['category'] as String? ?? 'other',
        reminderEnabled: true,
        reminderMinutesBefore: const [60, 15],
        createdAt: DateTime.now(),
      );

      return meeting;
    } catch (e) {
      _error = 'Failed to create meeting: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear pending meeting data
  void clearPendingData() {
    _pendingMeetingData = null;
    notifyListeners();
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _pendingMeetingData = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Add a system message
  void addSystemMessage(String message) {
    final systemMessage = ChatMessage(
      id: const Uuid().v4(),
      message: message,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(systemMessage);
    notifyListeners();
  }
}
