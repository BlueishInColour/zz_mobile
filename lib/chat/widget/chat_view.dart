import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart'; // Ensure MessageSender is here
import 'message_bubble.dart'; // Your existing MessageBubble

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Scroll to bottom when messages change and view is active
    // Provider.of<ChatProvider>(context).addListener(_scrollToBottomIfRelevant);
  }


  @override
  void dispose() {
    // Provider.of<ChatProvider>(context, listen: false).removeListener(_scrollToBottomIfRelevant);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // void _scrollToBottomIfRelevant() {
  //   if (mounted && _scrollController.hasClients) {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (mounted && _scrollController.hasClients) { // Check mounted again
  //           _scrollController.animateTo(
  //             0.0,
  //             duration: const Duration(milliseconds: 300),
  //             curve: Curves.easeOut,
  //           );
  //         }
  //       });
  //   }
  // }


  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
      _messageController.clear();
      // _scrollToBottomIfRelevant(); // Call after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes for rebuilding the message list
    final chatProvider = context.watch<ChatProvider>();

    // This is a common pattern to scroll when the list updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients && chatProvider.messages.isNotEmpty) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 100), // Faster scroll for new messages
          curve: Curves.easeOut,
        );
      }
    });


    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.all(8.0),
            itemCount: chatProvider.messages.length,
            itemBuilder: (ctx, index) {
              final message = chatProvider.messages[index];
              return MessageBubble(
                message: message,
                // Logic for isMe needs to compare message.senderId with chatProvider.userId
                isMe: message.sender == MessageSender.user,
              );
            },
          ),
        ),
        _buildMessageComposer(),
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Send a message...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}