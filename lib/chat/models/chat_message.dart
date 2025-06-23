enum MessageSender {
  user,
  peer, // For P2P
  ai,
  system, // For system messages like "User X joined"
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final MessageSender sender;
  final String? senderId; // Optional: To identify specific users in P2P

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
    this.senderId,
  });

  // Optional: Factory constructor for JSON deserialization if needed
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      sender: _senderFromString(json['senderType'] ?? 'system'),
      senderId: json['senderId'],
    );
  }

  static MessageSender _senderFromString(String senderStr) {
    switch (senderStr.toLowerCase()) {
      case 'user':
        return MessageSender.user;
      case 'peer':
        return MessageSender.peer;
      case 'ai':
        return MessageSender.ai;
      default:
        return MessageSender.system;
    }
  }
}