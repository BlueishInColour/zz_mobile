// widgets/assistive_prompt_screen_widget.dart (Create this new file or ensure it exists)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chats_tab_content_state_provider.dart'; // Adjust path
import '../providers/chat_provider.dart'; // Adjust path

class AssistivePromptScreenWidget extends StatelessWidget {
  const AssistivePromptScreenWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This Scaffold is optional. If ChatsTabScreen provides an overall Scaffold
    // and AppBar, this might just be a Column or GridView.
    // For now, let's give it its own for clarity, assuming it might have a title.
    return Scaffold(
      appBar: AppBar(
        // title: Text("Start a new chat"), // Or this title could be part of ChatsTabScreen's AppBar
        backgroundColor: Colors.transparent, // Example: make it blend if part of a larger view
        elevation: 0,
        automaticallyImplyLeading: false, // If no back navigation is needed from here within the tab
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "How can I help you?", // Or "Welcome!" or similar
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // This is where your GridView of prompts will go.
            // For now, let's use a simple button to test the AI chat flow.
            Center( // Centering the example button
              child: ElevatedButton.icon(
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Text("Chat with AI Assistant"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () {
                  // 1. Prepare ChatProvider for AI chat
                  Provider.of<ChatProvider>(context, listen: false).switchToAiChat();
                  // 2. Tell ChatsTabContentStateProvider to show the chat view
                  Provider.of<ChatsTabContentStateProvider>(context, listen: false).showAiChatScreen();
                },
              ),
            ),
            const SizedBox(height: 16),
            // Example of another prompt (you'd have more in a grid)
            // Center(
            //   child: ElevatedButton(
            //     child: Text("Start Chat with Sample Peer (Test)"),
            //     onPressed: () {
            //       Provider.of<ChatProvider>(context, listen: false)
            //           .switchToP2pChat("sample_peer_id", "Sample Peer", null);
            //       Provider.of<ChatsTabContentStateProvider>(context, listen: false)
            //           .showP2pChatScreen("sample_peer_id", "Sample Peer", null);
            //     },
            //   ),
            // ),

            // Placeholder for your future GridView
            // Expanded(
            //   child: GridView.count(
            //     crossAxisCount: 2,
            //     children: <Widget>[
            //       // Your prompt items here
            //     ],
            //   ),
            // ),
            const Spacer(), // Pushes content to the top if Column is not full
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  "Select an option to get started.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}