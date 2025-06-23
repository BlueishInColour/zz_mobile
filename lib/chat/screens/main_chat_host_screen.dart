// main_chat_host_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Ensure correct path to your ChatProvider
import '../widgets/chat_view.dart';
import 'contacts_screen.dart';        // Your contacts management screen

class MainChatHostScreen extends StatelessWidget {
  const MainChatHostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to ChatProvider for changes to rebuild AppBar and body if needed
    // Using context.watch<ChatProvider>() ensures rebuilds on notifyListeners()
    final chatProvider = context.watch<ChatProvider>();

    String appBarTitle;

    // Determine AppBar title based on the state from ChatProvider
    if (chatProvider.isAiChatActive) {
      appBarTitle = chatProvider.aiDisplayName; // Accessing the defined AI display name
    } else {
      // For P2P chat, use activePeerDisplayName or a fallback
      appBarTitle = chatProvider.activePeerDisplayName ?? "Chat";
    }

    return Scaffold(
      appBar: AppBar(
        // If this screen is always pushed onto a stack, a leading back button
        // might be automatically added by Flutter depending on the Navigator.
        // If you need explicit control or to pop to a specific state:
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Example: If you have a state provider to switch back to assistive screen
        //     // Provider.of<ChatsTabContentStateProvider>(context, listen: false).showAssistiveScreen();
        //     // Or, if just popping the current screen is enough:
        //     // if (Navigator.canPop(context)) {
        //     //   Navigator.pop(context);
        //     // }
        //   },
        // ),
        title: Text(appBarTitle),
        actions: [
          // Display loading indicator from ChatProvider
          // Ensure 'isLoading' getter exists in your ChatProvider
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))),
            ),
          // Button to navigate to a dedicated Contacts Management Screen
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsScreen()),
              );
            },
          ),
        ],
      ),
      body: const ChatView(), // ChatView widget handles displaying current chat messages and input bar
      // If you implement BottomNavigationBar as part of THIS screen (unlikely if it's within a tab), it would go here.
    );
  }
}