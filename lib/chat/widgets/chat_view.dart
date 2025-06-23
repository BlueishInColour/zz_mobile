// screens/chat_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Adjust
import '../models/chat_message.dart';
import 'chat_input_bar.dart';
import 'message_bubble.dart';    // Adjust

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    return Scaffold(
      // AppBar can be managed by the parent screen (TabScreenWrapper) or here
      // For simplicity now, let's assume parent handles AppBar.
      // If you want an AppBar specific to the chat:
      appBar: AppBar(
        title: Text(
          chatProvider.isAiChatActive
              ? chatProvider.aiDisplayName // Accessing AI name from provider
              : chatProvider.activePeerDisplayName ?? "Chat",
        ),
        // Add other AppBar actions if needed
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                "No messages yet.\nStart the conversation!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              reverse: true, // To show newest messages at the bottom
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (ctx, index) {
                final message = messages[messages.length - 1 - index]; // Access in reverse
                final isMe = message.senderId == chatProvider.currentUserId;

                if (message.senderType == MessageSender.system) {
                  return Padding( // Simple system message display
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      message.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                }

                return MessageBubble(
                  messageText: message.text,
                  senderAvatarUrl: message.senderAvatarUrl,
                  senderDisplayName: message.senderDisplayName,
                  timestamp: message.timestamp,
                  status: message.status, // Pass the status
                  isMe: isMe,
                );
              },
            ),
          ),
          ChatInputBar(),
        ],
      ),
    );
  }
}