// screens/chats_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Adjust path
import '../widgets/assistive_prompt_screen_widget.dart'; // Adjust path
import '../widgets/draggable_contacts_panel_for_chat.dart'; // Ensure this uses your actual Contact model
import 'main_chat_host_screen.dart'; // Your existing screen

// Assuming your Contact model is defined in draggable_contacts_panel_for_chat.dart or imported there

class ChatsTabScreen extends StatefulWidget { // <<< CHANGED to StatefulWidget
  const ChatsTabScreen({Key? key}) : super(key: key);

  @override
  _ChatsTabScreenState createState() => _ChatsTabScreenState();
}

class _ChatsTabScreenState extends State<ChatsTabScreen> { // <<< NEW State class
  bool _isPanelExpanded = false; // Track panel state, default to collapsed

  @override
  void initState() {
    super.initState();
    // Set initial state based on DraggableContactsPanelForChat's isInitiallyExpanded
    // If you always want it initially collapsed as per your previous request,
    // _isPanelExpanded can remain false.
    // If DraggableContactsPanelForChat's isInitiallyExpanded could be true, you'd sync here.
    // For now, assuming DraggableContactsPanelForChat.isInitiallyExpanded is false.
    _isPanelExpanded = false;
  }

  void _navigateToChat(BuildContext context, Contact contact) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (contact.isAi) {
      chatProvider.switchToAiChat();
    } else {
      chatProvider.switchToP2pChat(contact.id, contact.displayName, contact.avatarUrl);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainChatHostScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "zuno",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          DraggableContactsPanelForChat(
            panelWidthCollapsed: 68.0,
            panelWidthExpanded: 250.0,
            isInitiallyExpanded: _isPanelExpanded, // Use state here, or directly false
            contacts: [
              Contact(id: 'ai_dummy_id', displayName: 'AI Assistant', isAi: true, avatarUrl: null),
              Contact(id: 'peer1_dummy_id', displayName: 'Jane Doe', avatarUrl: 'https://i.pravatar.cc/150?img=3'),
              Contact(id: 'peer2_dummy_id', displayName: 'John Smith', avatarUrl: 'https://i.pravatar.cc/150?img=4'),
            ],
            onContactSelected: (contact) {
              _navigateToChat(context, contact);
            },
            onExpansionChanged: (isExpanded) { // <<< USE THE CALLBACK
              setState(() {
                _isPanelExpanded = isExpanded;
              });
            },
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Conditionally render or wrap AssistivePromptScreenWidget
          // In ChatsTabScreen's build method, replace the if/else for AssistivePromptScreenWidget:

// ...
          Expanded( // Keep Expanded to define the available space
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200), // Adjust duration
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
                // Or SlideTransition, SizeTransition, etc.
              },
              child: _isPanelExpanded
                  ? const SizedBox.shrink() // Or some minimal placeholder
                  : const AssistivePromptScreenWidget(), // Key it if necessary for animations
            ),
          ),
// ...// Takes no space
        ],
      ),
    );
  }
}