import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/meeting_provider.dart';
import '../widgets/chat_bubble.dart';

/// AI chat screen for natural language meeting scheduling
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (chatProvider.messages.isEmpty) {
        chatProvider.addSystemMessage(
          'Hello! I\'m your AI meeting assistant. You can tell me things like:\n\n'
          '• "Schedule team meeting tomorrow at 3 PM"\n'
          '• "Meeting with Sarah next Monday at 10 AM for 2 hours"\n'
          '• "Lunch with mom on Friday at 12:30"\n\n'
          'How can I help you today?',
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(message);

    _scrollToBottom();
  }

  Future<void> _confirmAndCreateMeeting() async {
    final chatProvider = context.read<ChatProvider>();
    final meetingProvider = context.read<MeetingProvider>();

    final meeting = chatProvider.createMeetingFromPendingData();
    if (meeting == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create meeting. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final success = await meetingProvider.addMeeting(meeting);

    if (mounted) {
      if (success) {
        chatProvider.clearPendingData();
        final meetingDate = '${meeting.dateTime.month}/${meeting.dateTime.day}';
        chatProvider.addSystemMessage(
          '✅ Meeting "${meeting.title}" created successfully for $meetingDate! Go to the Calendar tab and select that date to view it.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meeting created! Check Calendar on $meetingDate'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        final error = meetingProvider.error ?? 'Unknown error';
        chatProvider.addSystemMessage(
          '❌ Failed to create meeting: $error',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().clearMessages();
              context.read<ChatProvider>().addSystemMessage(
                    'Conversation cleared. How can I help you schedule a meeting?',
                  );
            },
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatProvider.messages.length +
                      (chatProvider.isProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length) {
                      return const TypingIndicator();
                    }

                    final message = chatProvider.messages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.pendingMeetingData != null) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      top: BorderSide(color: Colors.blue[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ready to create this meeting?',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          chatProvider.clearPendingData();
                          chatProvider.addSystemMessage(
                            'Meeting creation cancelled. What else can I help you with?',
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _confirmAndCreateMeeting,
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return IconButton(
                      icon: const Icon(Icons.send),
                      onPressed:
                          chatProvider.isProcessing ? null : _sendMessage,
                      color: Theme.of(context).colorScheme.primary,
                      iconSize: 28,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
