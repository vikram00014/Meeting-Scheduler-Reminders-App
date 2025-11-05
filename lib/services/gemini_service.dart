import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for interacting with Google Gemini API
/// Handles natural language processing for meeting scheduling
class GeminiService {
  static final GeminiService instance = GeminiService._init();

  GeminiService._init();

  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// System prompt that instructs Gemini to return structured JSON
  String get _systemPrompt => '''
You are a meeting scheduling assistant. Your job is to extract meeting information from user requests and return it in a strict JSON format.

CRITICAL RULES:
1. ALWAYS respond with valid JSON only, no additional text
2. Use the exact field names specified below
3. If information is missing or ambiguous, ask a clarifying question in JSON format
4. Extract participant contact information (emails, phone numbers) when mentioned

JSON FORMAT FOR MEETING EXTRACTION:
{
  "success": true,
  "data": {
    "title": "Meeting title",
    "date": "YYYY-MM-DD",
    "time": "HH:MM" (24-hour format),
    "duration": 60 (in minutes, default to 60 if not specified),
    "description": "Meeting description or null",
    "participants": ["participant1 (email@example.com)", "participant2 (+1234567890)"] (or empty array, include contact info if provided),
    "category": "work" or "personal" or "other" (default to "other"),
    "notifyParticipants": true or false (true if user mentions sending invitation/notification)
  }
}

JSON FORMAT FOR CLARIFICATION QUESTIONS:
{
  "success": false,
  "question": "What time should the meeting start?",
  "context": "Meeting with John tomorrow"
}

EXAMPLES:

User: "Schedule team meeting tomorrow at 3 PM"
Response: {"success": true, "data": {"title": "Team Meeting", "date": "TOMORROW", "time": "15:00", "duration": 60, "description": null, "participants": [], "category": "work", "notifyParticipants": false}}

User: "Meeting with Sarah next Monday and send her invitation to sarah@email.com"
Response: {"success": true, "data": {"title": "Meeting with Sarah", "date": "NEXT_MONDAY", "time": null, "duration": 60, "description": null, "participants": ["Sarah (sarah@email.com)"], "category": "other", "notifyParticipants": true}}

User: "Project review at 2 PM for 2 hours on Friday with john@company.com"
Response: {"success": true, "data": {"title": "Project Review", "date": "NEXT_FRIDAY", "time": "14:00", "duration": 120, "description": null, "participants": ["john@company.com"], "category": "work", "notifyParticipants": false}}

User: "Lunch with mom tomorrow 12:30, notify her at +1234567890"
Response: {"success": true, "data": {"title": "Lunch with Mom", "date": "TOMORROW", "time": "12:30", "duration": 60, "description": null, "participants": ["mom (+1234567890)"], "category": "personal", "notifyParticipants": true}}

IMPORTANT:
- For relative dates like "tomorrow", "next Monday", use the format specified and I will convert them
- Default duration is 60 minutes if not specified
- Infer category from context (work-related = "work", family/friends = "personal", others = "other")
- Extract participant names with their contact info (email or phone) when provided
- Set notifyParticipants to true if user mentions: "send invitation", "notify", "send invite", "email them", "text them"
- Current date/time context will be provided with each request
''';

  /// Parse user input and extract meeting information using Gemini AI
  /// Returns a Map with either structured meeting data or a clarifying question
  Future<Map<String, dynamic>> parseMeetingRequest(String userInput) async {
    try {
      // Add current date/time context to help with relative date parsing
      final now = DateTime.now();
      final contextualInput = '''
Current date and time: ${now.toString()}
Current day: ${_getDayName(now.weekday)}

User request: $userInput

Remember to return ONLY valid JSON, nothing else.
''';

      final response = await _callGeminiAPI(contextualInput);

      if (response['success'] == true) {
        return _processSuccessfulResponse(response, now);
      } else {
        return response;
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to process request: ${e.toString()}',
      };
    }
  }

  /// Process successful API response and convert relative dates to absolute dates
  Map<String, dynamic> _processSuccessfulResponse(
    Map<String, dynamic> response,
    DateTime now,
  ) {
    final data = response['data'] as Map<String, dynamic>;
    final dateStr = data['date'] as String;

    // Convert relative dates to absolute dates (case-insensitive, flexible matching)
    final dateStrUpper = dateStr.toUpperCase();
    DateTime meetingDate;

    if (dateStrUpper.contains('TOMORROW')) {
      meetingDate = now.add(const Duration(days: 1));
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('TODAY')) {
      meetingDate = now;
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('MONDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.monday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('TUESDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.tuesday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('WEDNESDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.wednesday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('THURSDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.thursday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('FRIDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.friday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('SATURDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.saturday);
      data['date'] = _formatDate(meetingDate);
    } else if (dateStrUpper.contains('SUNDAY')) {
      meetingDate = _getNextWeekday(now, DateTime.sunday);
      data['date'] = _formatDate(meetingDate);
    }

    return response;
  }

  /// Call Gemini API with retry logic and exponential backoff
  Future<Map<String, dynamic>> _callGeminiAPI(
    String prompt, {
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    Duration retryDelay = const Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        final url = Uri.parse('$_baseUrl?key=$_apiKey');

        final requestBody = {
          'contents': [
            {
              'parts': [
                {'text': _systemPrompt},
                {'text': prompt},
              ]
            }
          ],
          'generationConfig': {
            'temperature':
                0.2, // Lower temperature for more consistent JSON output
            'topK': 20,
            'topP': 0.8,
            'maxOutputTokens': 1024,
          }
        };

        final response = await http
            .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final text = jsonResponse['candidates'][0]['content']['parts'][0]
              ['text'] as String;

          // Extract JSON from response (in case there's extra text)
          final cleanedText = _extractJSON(text);
          final parsedData = jsonDecode(cleanedText);

          return parsedData as Map<String, dynamic>;
        } else if (response.statusCode == 429) {
          // Rate limit exceeded, retry with backoff
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Rate limit exceeded. Please try again later.');
          }
          await Future.delayed(retryDelay);
          retryDelay *= 2; // Exponential backoff
        } else {
          throw Exception(
              'API request failed: ${response.statusCode} - ${response.body}');
        }
      } on TimeoutException {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Request timed out. Please try again.');
        }
        await Future.delayed(retryDelay);
        retryDelay *= 2;
      } on SocketException {
        throw Exception('No internet connection. Please check your network.');
      } on FormatException {
        throw Exception(
            'Invalid response format from AI. Please try rephrasing your request.');
      }
    }

    throw Exception('Maximum retries exceeded. Please try again later.');
  }

  /// Extract JSON from text that might contain additional content
  String _extractJSON(String text) {
    // Remove markdown code blocks if present
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    // Find the first { and last }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start != -1 && end != -1 && end > start) {
      return cleaned.substring(start, end + 1);
    }

    return cleaned;
  }

  /// Get the next occurrence of a specific weekday
  DateTime _getNextWeekday(DateTime from, int weekday) {
    int daysToAdd = weekday - from.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
    return from.add(Duration(days: daysToAdd));
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
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

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await parseMeetingRequest('test connection');
      return response['error'] == null;
    } catch (e) {
      return false;
    }
  }
}
