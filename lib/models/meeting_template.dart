/// Meeting Template model for quick meeting creation
class MeetingTemplate {
  final String id;
  final String name; // Template name (e.g., "Daily Standup", "1-on-1")
  final String title; // Default meeting title
  final int durationMinutes;
  final String? description;
  final List<String> participants;
  final String category;
  final bool reminderEnabled;
  final List<int> reminderMinutesBefore;
  final String? meetingLink;
  final DateTime createdAt;

  MeetingTemplate({
    required this.id,
    required this.name,
    required this.title,
    this.durationMinutes = 60,
    this.description,
    this.participants = const [],
    this.category = 'work',
    this.reminderEnabled = true,
    this.reminderMinutesBefore = const [60, 15],
    this.meetingLink,
    required this.createdAt,
  });

  /// Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'durationMinutes': durationMinutes,
      'description': description,
      'participants': participants.join(','),
      'category': category,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderMinutesBefore': reminderMinutesBefore.join(','),
      'meetingLink': meetingLink,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory MeetingTemplate.fromMap(Map<String, dynamic> map) {
    return MeetingTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      title: map['title'] as String,
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
      meetingLink: map['meetingLink'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Copy with updated fields
  MeetingTemplate copyWith({
    String? id,
    String? name,
    String? title,
    int? durationMinutes,
    String? description,
    List<String>? participants,
    String? category,
    bool? reminderEnabled,
    List<int>? reminderMinutesBefore,
    String? meetingLink,
    DateTime? createdAt,
  }) {
    return MeetingTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      participants: participants ?? this.participants,
      category: category ?? this.category,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      meetingLink: meetingLink ?? this.meetingLink,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MeetingTemplate{id: $id, name: $name, title: $title}';
  }
}
