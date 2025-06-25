// providers/chats_tab_content_state_provider.dart
import 'package:flutter/material.dart';

enum ChatsViewType { assistive, aiChat, p2pChat }

class ChatsTabContentStateProvider with ChangeNotifier {
  ChatsViewType _currentViewType = ChatsViewType.assistive;
  // Store peer details if needed, though MainChatHostScreen gets them from ChatProvider
  // String? _activePeerId;
  // String? _activePeerDisplayName;
  // String? _activePeerAvatarUrl;

  ChatsViewType get currentViewType => _currentViewType;

  void showAiChatScreen() {
    _currentViewType = ChatsViewType.aiChat;
    notifyListeners();
  }

  void showP2pChatScreen(String peerId, String peerName, String? peerAvatar) {
    _currentViewType = ChatsViewType.p2pChat;
    // _activePeerId = peerId; // Store if needed by the view itself, but MainChatHostScreen uses ChatProvider
    notifyListeners();
  }

  void showAssistiveScreen() {
    _currentViewType = ChatsViewType.assistive;
    notifyListeners();
  }
}