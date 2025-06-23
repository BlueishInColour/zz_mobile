// providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart'; // Adjust import path

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  String _currentUserId = "user_me_123"; // Replace with actual logged-in user ID
  String? _currentUserAvatarUrl = "https://example.com/my_avatar.png"; // Replace
  String _currentUserDisplayName = "Me"; // Replace

  // For P2P chat context
  String? _activePeerId;
  String? _activePeerDisplayName;
  String? _activePeerAvatarUrl;

  // For AI chat context
  bool _isAiChatActive = false;
  final String _aiId = "ai_assistant_001";
  final String aiDisplayName = "AI Assistant";
  final String? _aiAvatarUrl = "https://example.com/ai_avatar.png"; // Replace

  List<ChatMessage> get messages => _messages;
  String get currentUserId => _currentUserId;
  String? get currentUserAvatarUrl => _currentUserAvatarUrl;
  String get currentUserDisplayName => _currentUserDisplayName;

  String? get activePeerId => _activePeerId;
  String? get activePeerDisplayName => _activePeerDisplayName;
  String? get activePeerAvatarUrl => _activePeerAvatarUrl;
  bool get isAiChatActive => _isAiChatActive;



  // --- Methods to Switch Chat Context ---
  void switchToAiChat() {
    _isAiChatActive = true;
    _activePeerId = null;
    _activePeerDisplayName = null;
    _activePeerAvatarUrl = null;
    _loadAiChatMessages(); // Placeholder: Load/initialize AI chat
    notifyListeners();
  }

  void switchToP2pChat(String peerId, String peerName, String? peerAvatar) {
    _isAiChatActive = false;
    _activePeerId = peerId;
    _activePeerDisplayName = peerName;
    _activePeerAvatarUrl = peerAvatar;
    _loadP2pChatMessages(peerId); // Placeholder: Load messages for this peer
    notifyListeners();
  }

  // --- Message Handling ---
  void _loadAiChatMessages() {
    // Replace with actual message loading logic (e.g., from local DB or API)
    _messages = [
      ChatMessage(
          id: 'ai1',
          text: 'Hello! How can I assist you today?',
          senderId: _aiId,
          senderDisplayName: aiDisplayName,
          senderAvatarUrl: _aiAvatarUrl,
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
          senderType: MessageSender.ai,
          status: MessageStatus.sent),
      ChatMessage(
          id: 'user1',
          text: 'Hi AI!',
          senderId: _currentUserId,
          senderDisplayName: _currentUserDisplayName,
          senderAvatarUrl: _currentUserAvatarUrl,
          timestamp: DateTime.now().subtract(Duration(minutes: 4)),
          senderType: MessageSender.user,
          status: MessageStatus.read),
    ];
    // Add a system message indicating chat start
    // _messages.insert(0, ChatMessage.system("AI chat started."));
    notifyListeners();
  }
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _loadP2pChatMessages(String peerId) async{
    _isLoading = true;
    notifyListeners();

    // Replace with actual message loading logic for this peer
    _messages = [
      ChatMessage(
          id: 'peer1',
          text: 'Hey there!',
          senderId: peerId, // Use the passed peerId
          senderDisplayName: _activePeerDisplayName ?? "Peer",
          senderAvatarUrl: _activePeerAvatarUrl,
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          senderType: MessageSender.user, // Peer is also a user
          status: MessageStatus.sent), // Incoming messages from peer are 'sent' from their perspective
      ChatMessage(
          id: 'user2',
          text: 'Hi! How are you?',
          senderId: _currentUserId,
          senderDisplayName: _currentUserDisplayName,
          senderAvatarUrl: _currentUserAvatarUrl,
          timestamp: DateTime.now().subtract(Duration(minutes: 50)),
          senderType: MessageSender.user,
          status: MessageStatus.delivered),
    ];
    // Add a system message indicating chat start with peer
    // _messages.insert(0, ChatMessage.system("Chat started with ${_activePeerDisplayName ?? 'Peer'}."));

    _isLoading = false;
    notifyListeners();
  }

  void addMessage(String text, {bool isFromCurrentUser = true}) {
    if (_isAiChatActive) {
      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: _currentUserId,
        senderDisplayName: _currentUserDisplayName,
        senderAvatarUrl: _currentUserAvatarUrl,
        timestamp: DateTime.now(),
        status: MessageStatus.sending, // Initially sending
      );
      _messages.add(userMessage);
      notifyListeners();

      // Simulate AI response (replace with actual AI logic)
      Future.delayed(Duration(seconds: 1), () {
        final aiResponse = ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: "I'm processing that: $text",
          senderId: _aiId,
          senderDisplayName: aiDisplayName,
          senderAvatarUrl: _aiAvatarUrl,
          timestamp: DateTime.now(),
          senderType: MessageSender.ai,
          status: MessageStatus.sent,
        );
        _messages.add(aiResponse);
        // Simulate updating user message status
        final userMsgIndex = _messages.indexWhere((m) => m.id == userMessage.id);
        if (userMsgIndex != -1) {
          _messages[userMsgIndex] = ChatMessage(
              id: userMessage.id, text: userMessage.text, senderId: userMessage.senderId,
              senderDisplayName: userMessage.senderDisplayName, senderAvatarUrl: userMessage.senderAvatarUrl,
              timestamp: userMessage.timestamp, status: MessageStatus.read); // Assume AI read it
        }
        notifyListeners();
      });

    } else if (_activePeerId != null) {
      // P2P chat message
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: isFromCurrentUser ? _currentUserId : _activePeerId!,
        senderDisplayName: isFromCurrentUser ? _currentUserDisplayName : _activePeerDisplayName ?? "Peer",
        senderAvatarUrl: isFromCurrentUser ? _currentUserAvatarUrl : _activePeerAvatarUrl,
        timestamp: DateTime.now(),
        status: isFromCurrentUser ? MessageStatus.sending : MessageStatus.sent,
      );
      _messages.add(newMessage);
      notifyListeners();

      // If it's your message, simulate sending and delivery
      if (isFromCurrentUser) {
        Future.delayed(Duration(milliseconds: 500), () => updateMessageStatus(newMessage.id, MessageStatus.sent));
        Future.delayed(Duration(seconds: 2), () => updateMessageStatus(newMessage.id, MessageStatus.delivered));
        // Simulate peer reading it later via another mechanism if needed
      }
    }
  }

  void updateMessageStatus(String messageId, MessageStatus newStatus) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final oldMsg = _messages[index];
      _messages[index] = ChatMessage(
        id: oldMsg.id,
        text: oldMsg.text,
        senderId: oldMsg.senderId,
        senderDisplayName: oldMsg.senderDisplayName,
        senderAvatarUrl: oldMsg.senderAvatarUrl,
        timestamp: oldMsg.timestamp,
        senderType: oldMsg.senderType,
        status: newStatus, // Updated status
        messageType: oldMsg.messageType,
      );
      notifyListeners();
    }
  }

// Helper to get peer info for bubbles if not directly on message (though we add it now)
// String? getPeerAvatarUrl(String peerId) => (peerId == _activePeerId) ? _activePeerAvatarUrl : null;
// String? getPeerDisplayName(String peerId) => (peerId == _activePeerId) ? _activePeerDisplayName : "Unknown";

}

