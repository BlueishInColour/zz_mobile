import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';

enum ChatType { ai, p2p }

class ChatProvider with ChangeNotifier {
  final SocketService _socketService;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatType _activeChatType = ChatType.ai;
  String? _activeRoomId;
  String? _activePeerDisplayName;
  final String _userId = "user_${DateTime.now().millisecondsSinceEpoch.remainder(10000)}";

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  ChatType get activeChatType => _activeChatType;
  String? get activeRoomId => _activeRoomId;
  String? get activePeerDisplayName => _activePeerDisplayName;
  String get userId => _userId;

  ChatProvider(this._socketService) {
    _socketService.setOnNewMessageListener(_handleNewMessage);
    _socketService.setOnRoomJoinedListener(_handleRoomJoined);
    _socketService.setOnUserJoinedListener(_handleUserJoinedRoom);
    _socketService.setOnUserLeftListener(_handleUserLeftRoom);
    _socketService.setOnErrorListener(_handleSocketError);

    // Initialize with AI chat by default.
    // The actual socket connection can be deferred to _ensureSocketConnected
    // or triggered by the UI when it's ready.
    switchToAiChat(isInitialSetup: true);
  }

  void _ensureSocketConnected() {
    if (!_socketService.isConnected()) {
      _socketService.connect();
    }
  }

  void _handleSocketError(dynamic data) {
    print("ChatProvider received socket error: $data");
    addMessage(ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: "Socket Error: $data. Please check connection.",
        timestamp: DateTime.now(),
        sender: MessageSender.system
    ));
    // _isLoading = false; // addMessage now handles this by default
    // notifyListeners(); // addMessage handles this
  }

  void _handleNewMessage(dynamic data) {
    print("ChatProvider handling new message: $data");
    if (data is! Map<String, dynamic>) {
      print("Received data is not a Map: $data");
      addMessage(ChatMessage(
          id: 'err_data_format_${DateTime.now().millisecondsSinceEpoch}',
          text: "Received malformed message from server.",
          timestamp: DateTime.now(),
          sender: MessageSender.system));
      return;
    }
    try {
      String messageText = data['text'] ?? data['message'] ?? data['response'] ?? 'No text content';
      String senderTypeStr = data['sender_type'] ?? (data.containsKey('response') ? 'ai' : 'peer');
      String? senderId = data['sender_id'];
      DateTime timestamp = data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp']) ?? DateTime.now()
          : DateTime.now();

      MessageSender senderType;
      if (senderTypeStr.toLowerCase() == 'ai') {
        senderType = MessageSender.ai;
      } else if (senderTypeStr.toLowerCase() == 'peer' && senderId != _userId) {
        senderType = MessageSender.peer;
      } else if (senderTypeStr.toLowerCase() == 'user' && senderId == _userId) {
        senderType = MessageSender.user;
      } else {
        // If it's from the current user but not marked as 'user', ignore it (server echo).
        if (senderId == _userId) return;
        senderType = MessageSender.system; // Or handle as appropriate
        print("Warning: Received message with unhandled sender_type or senderId: $data");
      }

      addMessage(ChatMessage(
        id: data['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: messageText,
        timestamp: timestamp,
        sender: senderType,
        senderId: senderId,
      ));
    } catch (e) {
      print("Error processing new message data: $e");
      addMessage(ChatMessage(
          id: 'err_proc_${DateTime.now().millisecondsSinceEpoch}',
          text: "Error processing message from server.",
          timestamp: DateTime.now(),
          sender: MessageSender.system));
    }
  }

  void _handleRoomJoined(dynamic data) {
    if (data is Map<String, dynamic> && data['room_id'] != null && data['status'] == 'success') {
      // _activeRoomId should already be set by switchToP2pChat. This confirms it.
      if (data['room_id'] == _activeRoomId) {
        addMessage(ChatMessage(
            id: 'sys_join_confirm_${DateTime.now().millisecondsSinceEpoch}',
            text: "Successfully joined room: ${data['room_id']}",
            timestamp: DateTime.now(),
            sender: MessageSender.system));
      } else {
        addMessage(ChatMessage( // This case should ideally not happen if flow is correct
            id: 'sys_join_mismatch_${DateTime.now().millisecondsSinceEpoch}',
            text: "Joined a different room: ${data['room_id']}. Expected: $_activeRoomId",
            timestamp: DateTime.now(),
            sender: MessageSender.system));
        // Potentially update _activeRoomId if this is a valid scenario (e.g. server redirects)
        // _activeRoomId = data['room_id'];
      }
    } else {
      addMessage(ChatMessage(
          id: 'sys_err_join_${DateTime.now().millisecondsSinceEpoch}',
          text: "Failed to join room. ${data['message'] ?? ''}",
          timestamp: DateTime.now(),
          sender: MessageSender.system));
    }
    // notifyListeners(); // addMessage handles this
  }

  void _handleUserJoinedRoom(dynamic data) {
    if (data is Map<String, dynamic> && data['user_id'] != null && data['user_id'] != _userId) {
      if (data['room_id'] == _activeRoomId) { // Check if it's for the current active room
        addMessage(ChatMessage(
            id: 'sys_user_join_${DateTime.now().millisecondsSinceEpoch}',
            text: "User ${data['user_id']} joined.",
            timestamp: DateTime.now(),
            sender: MessageSender.system));
      }
    }
  }

  void _handleUserLeftRoom(dynamic data) {
    if (data is Map<String, dynamic> && data['user_id'] != null && data['user_id'] != _userId) {
      if (data['room_id'] == _activeRoomId) { // Check if it's for the current active room
        addMessage(ChatMessage(
            id: 'sys_user_left_${DateTime.now().millisecondsSinceEpoch}',
            text: "User ${data['user_id']} left.",
            timestamp: DateTime.now(),
            sender: MessageSender.system));
      }
    }
  }

  // Unified addMessage
  void addMessage(ChatMessage message, {bool clearLoading = true}) {
    _messages.insert(0, message);
    if (clearLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void switchToAiChat({bool isInitialSetup = false}) {
    _ensureSocketConnected();
    _activeChatType = ChatType.ai;
    _activeRoomId = null;
    _activePeerDisplayName = "AI Assistant";
    _messages = []; // Clear messages for the new chat context

    if (!isInitialSetup) {
      addMessage(ChatMessage(
          id: 'sys_ai_switch_${DateTime.now().millisecondsSinceEpoch}',
          text: "Switched to AI Chat.",
          timestamp: DateTime.now(),
          sender: MessageSender.system));
    } else {
      addMessage(ChatMessage(
          id: 'sys_ai_initial_${DateTime.now().millisecondsSinceEpoch}',
          text: "Welcome! Chat with our AI Assistant.",
          timestamp: DateTime.now(),
          sender: MessageSender.system));
    }
    // notifyListeners(); // addMessage handles this
  }

  void switchToP2pChat(String contactId, String contactDisplayName) {
    _ensureSocketConnected();
    _activeChatType = ChatType.p2p;
    _activeRoomId = _generateP2pRoomId(_userId, contactId); // Sets the active room ID
    _activePeerDisplayName = contactDisplayName;
    _messages = []; // Clear messages for the new chat context

    addMessage(ChatMessage(
        id: 'sys_p2p_switch_${DateTime.now().millisecondsSinceEpoch}',
        text: "Connecting to chat with $contactDisplayName...",
        timestamp: DateTime.now(),
        sender: MessageSender.system));

    _socketService.joinRoom(_activeRoomId!, _userId);
    // notifyListeners(); // addMessage handles this, and joinRoom is async
  }

  String _generateP2pRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _ensureSocketConnected();

    final userMessage = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
      senderId: _userId,
    );
    // Add optimistically, don't clear loading for AI until response
    addMessage(userMessage, clearLoading: _activeChatType != ChatType.ai);


    if (_activeChatType == ChatType.ai) {
      _isLoading = true; // Show loading specifically for AI before sending
      notifyListeners(); // Notify for isLoading change
      _socketService.sendAiMessage(text, _userId);
    } else if (_activeChatType == ChatType.p2p && _activeRoomId != null) {
      // For P2P, isLoading was already set to false by addMessage or kept false
      _socketService.sendChatMessageToRoom(_activeRoomId!, text, _userId);
    }
  }

  void clearChat() { // This might be for a settings option "Clear current chat history"
    _messages = [];
    notifyListeners();
    // Optionally, add a system message
    addMessage(ChatMessage(
        id: 'sys_clear_${DateTime.now().millisecondsSinceEpoch}',
        text: "Chat history cleared.",
        timestamp: DateTime.now(),
        sender: MessageSender.system));
  }

  @override
  void dispose() {
    // If ChatProvider owns the lifecycle of the socket connection, disconnect here.
    // However, if SocketService is shared or managed by a higher-level widget,
    // this might not be the right place.
    // Example: _socketService.disconnect();
    super.dispose();
  }
}