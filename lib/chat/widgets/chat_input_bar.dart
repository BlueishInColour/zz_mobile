// widgets/chat_input_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Adjust

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({Key? key}) : super(key: key);

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _canSend = _textController.text.trim().isNotEmpty;
        });
      }
    });
  }

  void _sendMessage() {
    if (!_canSend) return;
    final text = _textController.text.trim();
    Provider.of<ChatProvider>(context, listen: false).addMessage(text);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Basic styling, enhance later
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Or another appropriate color
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.1),
            )
          ]
      ),
      child: Row(
        children: [
          // IconButton for attachments (placeholder for now)
          IconButton(
            icon: Icon(Icons.attach_file, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // TODO: Implement image/file picking
              print("Attach file pressed");
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]
                    : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8),
          // Dynamic Send/Record button
          IconButton(
            icon: Icon(
              _canSend ? Icons.send : Icons.mic,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _canSend ? _sendMessage : () {
              // TODO: Implement voice recording
              print("Record audio pressed");
            },
          ),
        ],
      ),
    );
  }
}