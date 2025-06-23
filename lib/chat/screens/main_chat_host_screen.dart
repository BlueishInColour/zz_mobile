import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widget/chat_view.dart';
import 'contacts_screen.dart'; // You'll create this next

class MainChatHostScreen extends StatelessWidget {
  const MainChatHostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    String appBarTitle;
    if (chatProvider.activeChatType == ChatType.ai) {
      appBarTitle = chatProvider.activePeerDisplayName ?? "AI Assistant";
    } else {
      appBarTitle = chatProvider.activePeerDisplayName ?? "Chat";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          // Display loading indicator from ChatProvider
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))),
            ),
          // Button to navigate to Contacts Screen
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
      body: const ChatView(), // The ChatView widget handles displaying current chat messages
      // If you implement BottomNavigationBar, it would go here.
    );
  }
}