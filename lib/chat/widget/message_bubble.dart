import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe; // To align user's messages to the right

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSystemMessage = message.sender == MessageSender.system;

    return Align(
      alignment: isSystemMessage
          ? Alignment.center
          : isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isSystemMessage
              ? Colors.grey.shade300
              : isMe
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.colorScheme.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe && !isSystemMessage ? const Radius.circular(12) : Radius.zero,
            bottomRight: !isMe && !isSystemMessage ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!isMe && message.sender != MessageSender.system && message.senderId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.sender == MessageSender.ai ? "AI" : (message.senderId ?? "Peer"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isSystemMessage
                    ? Colors.black87
                    : isMe
                    ? Colors.white
                    : Colors.white, // Assuming secondary color is dark enough for white text
                fontSize: 15,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isSystemMessage
                    ? Colors.black54
                    : isMe
                    ? Colors.white70
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}