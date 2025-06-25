// screens/chats_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Adjust path
// import '../providers/chats_tab_content_state_provider.dart'; // May not be needed here anymore for view switching
import '../widgets/assistive_prompt_screen_widget.dart'; // Adjust path
import '../widgets/draggable_contacts_panel_for_chat.dart'; // Ensure this uses your actual Contact model
import 'main_chat_host_screen.dart'; // Your existing screen

// Assuming your Contact model is defined in draggable_contacts_panel_for_chat.dart or imported there
// If not, you might need:
// import '../models/contact_model.dart';


// ChatContactsPanelPlaceholder is removed for brevity as DraggableContactsPanelForChat is used directly
// If you still need a placeholder for other reasons, it can be kept.

class ChatsTabScreen extends StatelessWidget {
  const ChatsTabScreen({Key? key}) : super(key: key);

  // Helper method to handle navigation to the chat screen
  void _navigateToChat(BuildContext context, Contact contact) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (contact.isAi) {
      chatProvider.switchToAiChat();
    } else {
      chatProvider.switchToP2pChat(contact.id, contact.displayName, contact.avatarUrl);
    }

    // --- CORRECTED NAVIGATION ---
    // Push MainChatHostScreen as a new route. It has its own Scaffold.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainChatHostScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // We no longer need to consume ChatsTabContentStateProvider to decide the whole screen structure.
    // This screen will always show its own Scaffold with the panel and assistive content.
    // Navigation to the full chat view happens by pushing MainChatHostScreen.

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "zuno", // Or your desired title for this screen
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false, // Assuming this is a main tab screen
      ),
      body: Row(
        children: [
          DraggableContactsPanelForChat(
            panelWidthCollapsed: 68.0,
            panelWidthExpanded: 250.0,
            isInitiallyExpanded: true, // Let's make it initially expanded for this example
            contacts: [
              // Replace with your actual data source / provider for contacts
              Contact(id: 'ai_dummy_id', displayName: 'AI Assistant', isAi: true, avatarUrl: null /* or actual URL */),
              Contact(id: 'peer1_dummy_id', displayName: 'Jane Doe', avatarUrl: 'https://i.pravatar.cc/150?img=3'),
              Contact(id: 'peer2_dummy_id', displayName: 'John Smith', avatarUrl: 'https://i.pravatar.cc/150?img=4'),
              // ... more contacts
            ],
            onContactSelected: (contact) {
              _navigateToChat(context, contact);
            },
          ),
          const VerticalDivider(width: 1, thickness: 1), // Optional visual separator
          const Expanded(
            child: AssistivePromptScreenWidget(), // This is your main content area when no chat is active
          ),
        ],
      ),
    );
  }
}