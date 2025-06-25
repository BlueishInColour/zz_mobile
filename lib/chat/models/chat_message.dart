// models/chat_message.dart
enum MessageSender { user, ai, system } // Added system for system messages
enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String text;
  final String senderId; // ID of the user or AI
  final DateTime timestamp;
  final MessageSender senderType;
  final MessageStatus status;

  // Optional: Store display info directly, or resolve in UI
  final String? senderDisplayName;
  final String? senderAvatarUrl;

  // Optional: For different types of content beyond text
  // final MessageContentType contentType;
  // final String? mediaUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.senderType,
    required this.status,
    this.senderDisplayName, // Can be set based on senderId + senderType
    this.senderAvatarUrl,  // Can be set based on senderId + senderType
  });

  // You might add copyWith methods here for easier updates
  ChatMessage copyWith({
    MessageStatus? status,
    // ... other fields you might want to update
  }) {
    return ChatMessage(
      id: id,
      text: text,
      senderId: senderId,
      timestamp: timestamp,
      senderType: senderType,
      status: status ?? this.status,
      senderDisplayName: senderDisplayName,
      senderAvatarUrl: senderAvatarUrl,
    );
  }
}