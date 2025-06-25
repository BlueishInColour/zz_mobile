// providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart'; // Adjust import path if needed
// Ensure ChatMessage uses MessageSender and MessageStatus enums

// Define the type of active chat
enum ActiveChatType {
  none, // No active chat selected
  ai,   // Chatting with the AI
  p2p   // Chatting with another user (peer-to-peer)
}

// Ensure these enums are defined, likely within your chat_message.dart or a shared models file
// enum MessageSender { user, ai } // Example
// enum MessageStatus { sending, sent, delivered, read, failed } // Example

class ChatProvider with ChangeNotifier {
  // --- Core State ---
  List<ChatMessage> _messages = [];
  ActiveChatType _activeChatType = ActiveChatType.none;
  bool _isLoading = false;

  // --- Current User Details (Should be loaded from auth service) ---
  String _currentUserId = "user_me_123"; // Replace with actual logged-in user ID logic
  String? _currentUserAvatarUrl = "https://example.com/my_avatar.png"; // Replace
  String _currentUserDisplayName = "Me"; // Replace

  // --- AI Chat Details (Constants) ---
  final String _aiId = "ai_assistant_001";
  final String _aiDisplayName = "AI Assistant";
  final String? _aiAvatarUrl = "https://example.com/ai_avatar.png"; // Replace

  // --- Active P2P Chat Peer Details ---
  String? _activePeerId;
  String? _activePeerDisplayName;
  String? _activePeerAvatarUrl;

  // --- Getters ---
  List<ChatMessage> get messages => _messages;
  ActiveChatType get activeChatType => _activeChatType;
  bool get isLoading => _isLoading;

  String get currentUserId => _currentUserId;
  String? get currentUserAvatarUrl => _currentUserAvatarUrl;
  String get currentUserDisplayName => _currentUserDisplayName;

  // Getters for AI info (useful if needed directly in UI)
  String get aiId => _aiId;
  String get aiDisplayName => _aiDisplayName;
  String? get aiAvatarUrl => _aiAvatarUrl;

  // Getters for active peer info
  String? get activePeerId => (_activeChatType == ActiveChatType.p2p) ? _activePeerId : null;
  String? get activePeerDisplayName => (_activeChatType == ActiveChatType.p2p) ? _activePeerDisplayName : null;
  String? get activePeerAvatarUrl => (_activeChatType == ActiveChatType.p2p) ? _activePeerAvatarUrl : null;


  // --- Methods to Switch Chat Context ---
  void switchToAiChat() {
    if (_activeChatType == ActiveChatType.ai) return; // Already in AI chat

    _activeChatType = ActiveChatType.ai;
    // Clear P2P specific info
    _activePeerId = null;
    _activePeerDisplayName = null;
    _activePeerAvatarUrl = null;

    _loadAiChatMessages();
    notifyListeners();
  }

  void switchToP2pChat(String peerId, String peerName, String? peerAvatar) {
    if (_activeChatType == ActiveChatType.p2p && _activePeerId == peerId) return; // Already in chat with this peer

    _activeChatType = ActiveChatType.p2p;
    _activePeerId = peerId;
    _activePeerDisplayName = peerName;
    _activePeerAvatarUrl = peerAvatar;

    _loadP2pChatMessages(peerId);
    notifyListeners();
  }

  void clearActiveChat() {
    if (_activeChatType == ActiveChatType.none) return;

    _activeChatType = ActiveChatType.none;
    _messages = []; // Clear messages when no chat is active
    _activePeerId = null;
    _activePeerDisplayName = null;
    _activePeerAvatarUrl = null;
    notifyListeners();
  }

  // --- Message Loading (Placeholders - Implement actual data fetching) ---
  Future<void> _loadAiChatMessages() async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Replace with actual message loading logic (e.g., from local DB or API)
    _messages = [
      ChatMessage(
          id: 'ai1',
          text: 'Hello! How can I assist you today?',
          senderId: _aiId, // Make sure ChatMessage has senderId
          // The following fields like senderDisplayName, senderAvatarUrl, senderType
          // might be directly part of ChatMessage or resolved in the UI.
          // For now, I'm assuming they are part of ChatMessage as in your original.
          senderDisplayName: _aiDisplayName,
          senderAvatarUrl: _aiAvatarUrl,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          senderType: MessageSender.ai, // Assuming MessageSender enum exists
          status: MessageStatus.sent),   // Assuming MessageStatus enum exists
      ChatMessage(
          id: 'user1_ai_reply', // Different ID from P2P
          text: 'Hi AI!',
          senderId: _currentUserId,
          senderDisplayName: _currentUserDisplayName,
          senderAvatarUrl: _currentUserAvatarUrl,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          senderType: MessageSender.user,
          status: MessageStatus.read),
    ];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadP2pChatMessages(String peerId) async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Replace with actual message loading logic for this peer
    _messages = [
      ChatMessage(
          id: 'peer1_msg', // Different ID from AI
          text: 'Hey there!',
          senderId: peerId,
          senderDisplayName: _activePeerDisplayName ?? "Peer",
          senderAvatarUrl: _activePeerAvatarUrl,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          senderType: MessageSender.user, // Peer is also a user
          status: MessageStatus.sent),
      ChatMessage(
          id: 'user2_p2p_reply',
          text: 'Hi! How are you?',
          senderId: _currentUserId,
          senderDisplayName: _currentUserDisplayName,
          senderAvatarUrl: _currentUserAvatarUrl,
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
          senderType: MessageSender.user,
          status: MessageStatus.delivered),
    ];
    _isLoading = false;
    notifyListeners();
  }

  // --- Message Handling ---
  void addMessage(String text) {
    if (_activeChatType == ActiveChatType.none) return; // Cannot send message if no chat is active

    ChatMessage newMessage;

    if (_activeChatType == ActiveChatType.ai) {
      newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: _currentUserId,
        senderDisplayName: _currentUserDisplayName,
        senderAvatarUrl: _currentUserAvatarUrl,
        timestamp: DateTime.now(),
        senderType: MessageSender.user, // User sending to AI
        status: MessageStatus.sending,
      );
      _messages.add(newMessage); // Or _messages.insert(0, newMessage) if reverse: true in ListView
      notifyListeners();

      // Simulate AI response
      _simulateAiResponse(newMessage.id, text);

    } else if (_activeChatType == ActiveChatType.p2p && _activePeerId != null) {
      newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        senderId: _currentUserId, // Message is from the current user
        senderDisplayName: _currentUserDisplayName,
        senderAvatarUrl: _currentUserAvatarUrl,
        timestamp: DateTime.now(),
        senderType: MessageSender.user,
        status: MessageStatus.sending,
      );
      _messages.add(newMessage); // Or _messages.insert(0, newMessage)
      notifyListeners();

      // Simulate sending and delivery for P2P
      _simulateP2pMessageStatusUpdate(newMessage.id);
    }
  }

  // Helper for AI response simulation
  Future<void> _simulateAiResponse(String originalMessageId, String userText) async {
    // Simulate updating original user message to 'read' by AI
    await Future.delayed(const Duration(milliseconds: 200));
    updateMessageStatus(originalMessageId, MessageStatus.read);

    // Simulate AI thinking and responding
    await Future.delayed(const Duration(seconds: 1));
    final aiResponse = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: "I'm processing that: $userText (AI simulated response)",
      senderId: _aiId,
      senderDisplayName: _aiDisplayName,
      senderAvatarUrl: _aiAvatarUrl,
      timestamp: DateTime.now(),
      senderType: MessageSender.ai,
      status: MessageStatus.sent,
    );
    _messages.add(aiResponse); // Or _messages.insert(0, aiResponse)
    notifyListeners();
  }

  // Helper for P2P message status simulation
  Future<void> _simulateP2pMessageStatusUpdate(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    updateMessageStatus(messageId, MessageStatus.sent);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500)); // Total 2 seconds
    updateMessageStatus(messageId, MessageStatus.delivered);
    // To simulate 'read', you'd typically get an event from the peer.
    // For now, we can add a manual trigger if needed for testing:
    // await Future.delayed(const Duration(seconds: 3));
    // updateMessageStatus(messageId, MessageStatus.read);
  }

  // To receive a message (e.g., from a peer via WebSocket or push notification)
  void receiveMessage(ChatMessage message) {
    // Basic check to ensure it's not a duplicate if you have robust IDs
    // if (_messages.any((m) => m.id == message.id)) return;

    _messages.add(message); // Or _messages.insert(0, message)
    notifyListeners();

    // If this received message is in the active P2P chat and not from current user,
    // you might want to mark current user's last message to this peer as 'read' if applicable,
    // or handle unread counts.
  }


  void updateMessageStatus(String messageId, MessageStatus newStatus) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final oldMsg = _messages[index];
      // Create a new ChatMessage instance with updated status
      // This is good practice for immutability with Provider
      _messages[index] = ChatMessage(
        id: oldMsg.id,
        text: oldMsg.text,
        senderId: oldMsg.senderId,
        senderDisplayName: oldMsg.senderDisplayName,
        senderAvatarUrl: oldMsg.senderAvatarUrl,
        timestamp: oldMsg.timestamp,
        senderType: oldMsg.senderType,
        status: newStatus, // Updated status
        // Ensure all other relevant fields from ChatMessage are copied
        // messageType: oldMsg.messageType, // If you had this field from original
      );
      notifyListeners();
    }
  }

  // --- User Profile Management (Example - load from auth) ---
  void loadUserProfile() {
    // In a real app, this would come from your authentication service
    // For example:
    // final user = _authService.currentUser;
    // _currentUserId = user.id;
    // _currentUserDisplayName = user.displayName;
    // _currentUserAvatarUrl = user.avatarUrl;
    // notifyListeners();
  }

// Call this on provider initialization if needed, or when user logs in.
// ChatProvider() {
//   loadUserProfile();
// }
}