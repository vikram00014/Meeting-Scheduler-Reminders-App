/// Chat message model for the AI assistant conversation
class ChatMessage {
  final String id;
  final String message;
  final bool isUser; // true if message is from user, false if from AI
  final DateTime timestamp;
  final Map<String, dynamic>?
      structuredData; // Parsed meeting data from AI response

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.structuredData,
  });

  /// Convert to Map for local storage if needed
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'structuredData': structuredData?.toString(),
    };
  }

  /// Create from Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      message: map['message'] as String,
      isUser: (map['isUser'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      structuredData: map['structuredData'] as Map<String, dynamic>?,
    );
  }
}
