import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/chat_message.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String recipientName;
  final String jobTitle;

  const ChatScreen({
    super.key,
    required this.recipientName,
    required this.jobTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi, I\'ll be there in 20 minutes.',
      'isMe': true,
      'time': '10:30 AM',
    },
    {
      'text': 'Great, see you soon!',
      'isMe': false,
      'time': '10:31 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipientName,
              style: AppTextStyles.h3,
            ),
            Text(
              widget.jobTitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatMessage(
                  message: message['text'],
                  isMe: message['isMe'],
                  time: message['time'],
                );
              },
            ),
          ),
          // Input
          ChatInput(
            controller: _messageController,
            onSend: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': message,
          'isMe': true,
          'time': '${DateTime.now().hour}:${DateTime.now().minute}',
        });
      });
      _messageController.clear();
    }
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(
              icon: Icons.image,
              title: 'Share Photos',
              onTap: () {
                // TODO: Implement photo sharing
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              icon: Icons.location_on,
              title: 'Share Location',
              onTap: () {
                // TODO: Implement location sharing
                Navigator.pop(context);
              },
            ),
            _buildOptionItem(
              icon: Icons.file_copy,
              title: 'Share Files',
              onTap: () {
                // TODO: Implement file sharing
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: AppTextStyles.bodyLarge),
      onTap: onTap,
    );
  }
}