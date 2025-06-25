// main_chat_host_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chats_tab_content_state_provider.dart'; // Adjust
import '../providers/chat_provider.dart'; // Adjust
// Import your ChatView and ChatInputBar (or ensure ChatView contains ChatInputBar)
import '../widgets/chat_view.dart';

class MainChatHostScreen extends StatelessWidget {
  const MainChatHostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    String chatTitle = "Chat";
    if (chatProvider.activeChatType == ActiveChatType.ai) {
      chatTitle = "AI Assistant";
    } else if (chatProvider.activeChatType == ActiveChatType.p2p &&
        chatProvider.activePeerDisplayName != null) {
      chatTitle = chatProvider.activePeerDisplayName!;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back to Chats List",
          onPressed: () {
            Provider.of<ChatsTabContentStateProvider>(context, listen: false)
                .showAssistiveScreen();
          },
        ),
        title: Text(chatTitle),
        // Add any chat-specific actions like video call, info etc.
      ),
      // NO bottomNavigationBar HERE
      body: const ChatView(), // ChatView now contains the messages list and the input bar
    );
  }
}