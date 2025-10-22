/// Meeting model class representing a scheduled meeting with all its details
class Meeting {
  final String id;
  final String title;
  final DateTime dateTime;
  final int durationMinutes; // Duration in minutes
  final String? description;
  final List<String> participants;
  final String category; // 'work', 'personal', 'other'
  final bool reminderEnabled;
  final List<int>
      reminderMinutesBefore; // e.g., [60, 15] for 1 hour and 15 minutes before
  final DateTime createdAt;
  final DateTime? updatedAt;

  Meeting({
    required this.id,
    required this.title,
    required this.dateTime,
    this.durationMinutes = 60,
    this.description,
    this.participants = const [],
    this.category = 'other',
    this.reminderEnabled = true,
    this.reminderMinutesBefore = const [60, 15],
    required this.createdAt,
    this.updatedAt,
  });

  /// Get the end time of the meeting
  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  /// Check if this meeting conflicts with another meeting
  bool conflictsWith(Meeting other) {
    // Check if meetings overlap
    return (dateTime.isBefore(other.endTime) &&
        endTime.isAfter(other.dateTime));
  }

  /// Convert Meeting to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'description': description,
      'participants': participants.join(','), // Store as comma-separated string
      'category': category,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderMinutesBefore': reminderMinutesBefore.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Meeting from Map (database retrieval)
  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as String,
      title: map['title'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      durationMinutes: map['durationMinutes'] as int,
      description: map['description'] as String?,
      participants: (map['participants'] as String).isEmpty
          ? []
          : (map['participants'] as String).split(','),
      category: map['category'] as String,
      reminderEnabled: (map['reminderEnabled'] as int) == 1,
      reminderMinutesBefore: (map['reminderMinutesBefore'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create Meeting from JSON (API response)
  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationMinutes: json['duration'] as int? ?? 60,
      description: json['description'] as String?,
      participants: json['participants'] != null
          ? List<String>.from(json['participants'] as List)
          : [],
      category: json['category'] as String? ?? 'other',
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] != null
          ? List<int>.from(json['reminderMinutesBefore'] as List)
          : [60, 15],
      createdAt: DateTime.now(),
    );
  }

  /// Convert Meeting to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'duration': durationMinutes,
      'description': description,
      'participants': participants,
      'category': category,
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  /// Create a copy of Meeting with updated fields
  Meeting copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    int? durationMinutes,
    String? description,
    List<String>? participants,
    String? category,
    bool? reminderEnabled,
    List<int>? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      category: category ?? this.category,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Meeting{id: $id, title: $title, dateTime: $dateTime, duration: $durationMinutes min}';
  }
}
