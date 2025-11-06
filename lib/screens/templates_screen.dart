import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/meeting_template.dart';
import '../services/database_service.dart';

/// Screen for managing meeting templates
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _databaseService = DatabaseService.instance;
  List<MeetingTemplate> _templates = [];
  bool _isLoading = true;
  static const uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _createDefaultTemplatesIfNeeded();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    final templates = await _databaseService.getAllTemplates();
    setState(() {
      _templates = templates;
      _isLoading = false;
    });
  }

  Future<void> _createDefaultTemplatesIfNeeded() async {
    final templates = await _databaseService.getAllTemplates();
    if (templates.isEmpty) {
      // Create default templates
      final defaultTemplates = [
        MeetingTemplate(
          id: uuid.v4(),
          name: 'Daily Standup',
          title: 'Daily Standup',
          durationMinutes: 15,
          description:
              'Quick team sync:\n- What did you do yesterday?\n- What will you do today?\n- Any blockers?',
          participants: const [],
          category: 'Work',
          reminderEnabled: true,
          reminderMinutesBefore: const [15],
          meetingLink: null,
          createdAt: DateTime.now(),
        ),
        MeetingTemplate(
          id: uuid.v4(),
          name: '1-on-1 Meeting',
          title: '1-on-1 Meeting',
          durationMinutes: 30,
          description: 'Personal check-in and discussion',
          participants: const [],
          category: 'Personal',
          reminderEnabled: true,
          reminderMinutesBefore: const [30],
          meetingLink: null,
          createdAt: DateTime.now(),
        ),
        MeetingTemplate(
          id: uuid.v4(),
          name: 'Team Meeting',
          title: 'Team Meeting',
          durationMinutes: 60,
          description: 'Team discussion and planning',
          participants: const [],
          category: 'Work',
          reminderEnabled: true,
          reminderMinutesBefore: const [15, 60],
          meetingLink: null,
          createdAt: DateTime.now(),
        ),
        MeetingTemplate(
          id: uuid.v4(),
          name: 'Sprint Planning',
          title: 'Sprint Planning',
          durationMinutes: 120,
          description: 'Plan upcoming sprint work',
          participants: const [],
          category: 'Work',
          reminderEnabled: true,
          reminderMinutesBefore: const [30],
          meetingLink: null,
          createdAt: DateTime.now(),
        ),
      ];

      for (final template in defaultTemplates) {
        await _databaseService.createTemplate(template);
      }
      await _loadTemplates();
    }
  }

  Future<void> _deleteTemplate(MeetingTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deleteTemplate(template.id);
      await _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _useTemplate(MeetingTemplate template) {
    Navigator.pop(context, template);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTemplateDialog(null),
            tooltip: 'Create Template',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No templates yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showTemplateDialog(null),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Template'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(template.category),
                          child: Icon(
                            _getCategoryIcon(template.category),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${template.durationMinutes} minutes'),
                            if (template.description != null &&
                                template.description!.isNotEmpty)
                              Text(
                                template.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showTemplateDialog(template),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteTemplate(template),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                        onTap: () => _useTemplate(template),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showTemplateDialog(MeetingTemplate? template) async {
    final result = await showDialog<MeetingTemplate>(
      context: context,
      builder: (context) => _TemplateDialog(template: template),
    );

    if (result != null) {
      if (template == null) {
        await _databaseService.createTemplate(result);
      } else {
        await _databaseService.updateTemplate(result);
      }
      await _loadTemplates();
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Meeting':
        return Colors.orange;
      case 'Other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Meeting':
        return Icons.people;
      case 'Other':
        return Icons.category;
      default:
        return Icons.event;
    }
  }
}

/// Dialog for creating/editing templates
class _TemplateDialog extends StatefulWidget {
  final MeetingTemplate? template;

  const _TemplateDialog({this.template});

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _category;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _titleController =
        TextEditingController(text: widget.template?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.template?.description ?? '');
    _category = widget.template?.category ?? 'Work';
    _duration = widget.template?.durationMinutes ?? 30;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.template == null ? 'New Template' : 'Edit Template'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Work', 'Personal', 'Meeting', 'Other']
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Duration: $_duration minutes'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _duration > 15
                        ? () => setState(() => _duration -= 15)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _duration += 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final template = MeetingTemplate(
      id: widget.template?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      durationMinutes: _duration,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      participants: widget.template?.participants ?? const [],
      category: _category,
      reminderEnabled: true,
      reminderMinutesBefore:
          widget.template?.reminderMinutesBefore ?? const [15],
      meetingLink: widget.template?.meetingLink,
      createdAt: widget.template?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, template);
  }
}
