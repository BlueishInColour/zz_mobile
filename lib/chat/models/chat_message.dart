// models/chat_message.dart

enum MessageSender { user, ai, system } // System for info messages like "User X joined"
enum MessageStatus { sending, sent, delivered, read, failed }
enum MessageType { text, image, audio, video } // For future use

class ChatMessage {
  final String id;
  final String text;
  final String senderId; // ID of the user/AI who sent it
  final String senderDisplayName; // Display name of sender
  final String? senderAvatarUrl; // URL for avatar
  final DateTime timestamp;
  final MessageSender senderType; // To differentiate AI/User/System easily
  final MessageStatus status;
  final MessageType messageType; // Default to text for now
  // Add fields for image/audio URLs later

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderDisplayName,
    this.senderAvatarUrl,
    required this.timestamp,
    this.senderType = MessageSender.user,
    this.status = MessageStatus.sending,
    this.messageType = MessageType.text,
  });

  // Example: Factory for creating a system message
  factory ChatMessage.system(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_system',
      text: text,
      senderId: 'system',
      senderDisplayName: 'System',
      timestamp: DateTime.now(),
      senderType: MessageSender.system,
      status: MessageStatus.sent, // System messages are considered sent
    );
  }
}