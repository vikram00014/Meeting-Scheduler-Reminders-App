import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/meeting.dart';
import '../providers/meeting_provider.dart';
import '../services/share_service.dart';

/// Screen for adding or editing meetings
class AddEditMeetingScreen extends StatefulWidget {
  final Meeting? meeting;
  final DateTime? initialDate;

  const AddEditMeetingScreen({
    super.key,
    this.meeting,
    this.initialDate,
  });

  @override
  State<AddEditMeetingScreen> createState() => _AddEditMeetingScreenState();
}

class _AddEditMeetingScreenState extends State<AddEditMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _participantsController;
  late TextEditingController _meetingLinkController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _duration;
  late String _category;
  late bool _reminderEnabled;
  late List<int> _reminderMinutes;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.meeting != null) {
      // Editing existing meeting
      final meeting = widget.meeting!;
      _titleController = TextEditingController(text: meeting.title);
      _descriptionController = TextEditingController(text: meeting.description);
      _participantsController = TextEditingController(
        text: meeting.participants.join(', '),
      );
      _meetingLinkController = TextEditingController(text: meeting.meetingLink);
      _selectedDate = meeting.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(meeting.dateTime);
      _duration = meeting.durationMinutes;
      _category = meeting.category;
      _reminderEnabled = meeting.reminderEnabled;
      _reminderMinutes = List.from(meeting.reminderMinutesBefore);
    } else {
      // Creating new meeting
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _participantsController = TextEditingController();
      _meetingLinkController = TextEditingController();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      _duration = 60;
      _category = 'other';
      _reminderEnabled = true;
      _reminderMinutes = [60, 15];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _participantsController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create DateTime from selected date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Parse participants
    final participants = _participantsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Create meeting object
    final meeting = Meeting(
      id: widget.meeting?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      dateTime: dateTime,
      durationMinutes: _duration,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      participants: participants,
      category: _category,
      reminderEnabled: _reminderEnabled,
      reminderMinutesBefore: _reminderMinutes,
      createdAt: widget.meeting?.createdAt ?? DateTime.now(),
      meetingLink: _meetingLinkController.text.trim().isEmpty
          ? null
          : _meetingLinkController.text.trim(),
    );

    final provider = context.read<MeetingProvider>();
    bool success;

    if (widget.meeting != null) {
      success = await provider.updateMeeting(meeting);
    } else {
      success = await provider.addMeeting(meeting);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.meeting != null
                  ? 'Meeting updated successfully'
                  : 'Meeting created successfully',
            ),
            backgroundColor: Colors.green,
            action: meeting.participants.isNotEmpty
                ? SnackBarAction(
                    label: 'Notify',
                    textColor: Colors.white,
                    onPressed: () => _showNotifyDialog(meeting),
                  )
                : null,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save meeting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show dialog to notify participants
  void _showNotifyDialog(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notify Participants'),
        content: const Text(
          'How would you like to notify the participants?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ShareService.shareMeeting(meeting);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  /// Show meeting link options dialog
  void _showMeetingLinkOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Meeting Links'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
              title: const Text('Zoom'),
              subtitle: const Text('Generate placeholder'),
              onTap: () {
                _meetingLinkController.text =
                    'https://zoom.us/j/${DateTime.now().millisecondsSinceEpoch % 1000000000}';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.red),
              title: const Text('Google Meet'),
              subtitle: const Text('Generate placeholder'),
              onTap: () {
                _meetingLinkController.text =
                    'https://meet.google.com/${_generateRandomCode()}';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups, color: Colors.purple),
              title: const Text('Microsoft Teams'),
              subtitle: const Text('Generate placeholder'),
              onTap: () {
                _meetingLinkController.text =
                    'https://teams.microsoft.com/l/meetup-join/${_generateRandomCode()}';
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Generate random code for meeting links
  String _generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(10, (index) => chars[(random + index) % chars.length])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting != null ? 'Edit Meeting' : 'New Meeting'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        timeFormat.format(
                          DateTime(2000, 1, 1, _selectedTime.hour,
                              _selectedTime.minute),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Duration
                  DropdownButtonFormField<int>(
                    value: _duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: const [
                      DropdownMenuItem(value: 15, child: Text('15 minutes')),
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 45, child: Text('45 minutes')),
                      DropdownMenuItem(value: 60, child: Text('1 hour')),
                      DropdownMenuItem(value: 90, child: Text('1.5 hours')),
                      DropdownMenuItem(value: 120, child: Text('2 hours')),
                      DropdownMenuItem(value: 180, child: Text('3 hours')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _duration = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'work',
                        child: Row(
                          children: [
                            Icon(Icons.work, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Work'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'personal',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Personal'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Row(
                          children: [
                            Icon(Icons.event, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Other'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Participants
                  TextFormField(
                    controller: _participantsController,
                    decoration: const InputDecoration(
                      labelText: 'Participants',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                      hintText: 'John (john@email.com), Sarah (+1234567890)',
                      helperText:
                          'Add names with email or phone (comma-separated)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // Meeting Link
                  TextFormField(
                    controller: _meetingLinkController,
                    decoration: InputDecoration(
                      labelText: 'Meeting Link (Optional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      hintText: 'https://zoom.us/j/123456789',
                      helperText: 'Zoom, Google Meet, Teams, etc.',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.auto_fix_high, size: 20),
                            onPressed: () {
                              _showMeetingLinkOptions();
                            },
                            tooltip: 'Quick Links',
                          ),
                        ],
                      ),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  // Reminder toggle
                  SwitchListTile(
                    title: const Text('Enable Reminders'),
                    value: _reminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _reminderEnabled = value;
                      });
                    },
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Reminder Times:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('15 minutes before'),
                      value: _reminderMinutes.contains(15),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _reminderMinutes.add(15);
                          } else {
                            _reminderMinutes.remove(15);
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('1 hour before'),
                      value: _reminderMinutes.contains(60),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _reminderMinutes.add(60);
                          } else {
                            _reminderMinutes.remove(60);
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('1 day before'),
                      value: _reminderMinutes.contains(1440),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _reminderMinutes.add(1440);
                          } else {
                            _reminderMinutes.remove(1440);
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('At meeting start time'),
                      value: _reminderMinutes.contains(0),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _reminderMinutes.add(0);
                          } else {
                            _reminderMinutes.remove(0);
                          }
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Save button
                  ElevatedButton(
                    onPressed: _saveMeeting,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.meeting != null
                          ? 'Update Meeting'
                          : 'Create Meeting',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
