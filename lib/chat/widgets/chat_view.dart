// lib/widgets/chat_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'chat_input_bar.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (chatProvider.messages.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom(animate: false);
      }
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.minScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  // UPDATED Helper to format time (WhatsApp style)
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat.jm().format(timestamp); // e.g., "5:08 PM" (AM/PM format)
      // If you strictly want 24-hour format for today:
      // return DateFormat.Hm().format(timestamp); // e.g., "17:08"
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      // Within the last week (but not today or yesterday)
      return DateFormat.E().format(timestamp); // e.g., "Mon", "Tue", "Wed"
    } else {
      // Older than a week
      return DateFormat('dd/MM/yyyy').format(timestamp); // e.g., "15/03/2023"
      // Or a slightly more readable format:
      // return DateFormat('MMM d, yyyy').format(timestamp); // e.g., "Mar 15, 2023"
    }
  }


  Widget _buildMessageStatusIcon(BuildContext context, ChatMessage message, bool isMe) {
    if (!isMe || (message.senderType == MessageSender.ai && message.status == MessageStatus.sending)) {
      return const SizedBox(height: 11);
    }

    IconData iconData;
    Color iconColor;

    switch (message.status) {
      case MessageStatus.sending:
        iconData = Icons.access_time_rounded;
        iconColor = Theme.of(context).iconTheme.color?.withOpacity(0.6) ?? Colors.grey.shade500;
        break;
      case MessageStatus.sent:
        iconData = Icons.done_rounded;
        iconColor = Theme.of(context).iconTheme.color?.withOpacity(0.6) ?? Colors.grey.shade500;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all_rounded;
        iconColor = Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey.shade600;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all_rounded;
        iconColor = Colors.blueAccent.shade400;
        break;
      case MessageStatus.failed:
        iconData = Icons.error_outline_rounded;
        iconColor = Colors.red.shade400;
        break;
      default:
        return const SizedBox(height: 11);
    }
    return Icon(iconData, size: 12, color: iconColor);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- COLOR CORRECTIONS ---
    // Define your "wine" color
    const Color wineColor = Color(0xFF722F37); // Example: A dark reddish-purple
    // For a slightly lighter wine color that might work better in light mode too:
    // const Color wineColor = Color(0xFF8C2D3E);

    final Color myBubbleColor = isDarkMode ? theme.colorScheme.primaryContainer : theme.colorScheme.primary;
    // UPDATED otherBubbleColor to use wineColor
    final Color otherBubbleColorDefined = isDarkMode ? wineColor.withOpacity(0.9) : wineColor;

    final Color myTextColor = isDarkMode ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onPrimary;
    // Ensure good contrast for text on wine color - typically white or a very light color
    final Color otherTextColorDefined = Colors.white.withOpacity(isDarkMode ? 0.90 : 0.95);


    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (chatProvider.messages.isNotEmpty && _scrollController.hasClients) {
            final latestMessage = chatProvider.messages.first;
            if (latestMessage.senderId == chatProvider.currentUserId ||
                _scrollController.position.extentBefore < 200) {
              _scrollToBottom();
            }
          }
        });

        return Column(
          children: [
            if (chatProvider.isLoading && chatProvider.messages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 3.0)),
              )
            else if (chatProvider.messages.isEmpty && chatProvider.activeChatType != ActiveChatType.none)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      chatProvider.activeChatType == ActiveChatType.ai
                          ? "Say something to start chatting with ${chatProvider.aiDisplayName}!"
                          : "No messages in this chat yet. Be the first to say something!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ),
                ),
              )
            else if (chatProvider.activeChatType == ActiveChatType.none)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Select a chat to view messages.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      // Correctly access messages when reverse is true
                      final message = chatProvider.messages[index];
                      final isMe = message.senderId == chatProvider.currentUserId;

                      String avatarDisplayText = "";
                      if (message.senderDisplayName != null && message.senderDisplayName!.isNotEmpty) {
                        final names = message.senderDisplayName!.trim().split(' ');
                        avatarDisplayText = names[0][0].toUpperCase();
                        if (names.length > 1 && names[1].isNotEmpty) {
                          avatarDisplayText += names[1][0].toUpperCase();
                        }
                      } else if (isMe) {
                        avatarDisplayText = "ME";
                      } else {
                        avatarDisplayText = message.senderType == MessageSender.ai ? "AI" : "P";
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start, // All bubbles aligned left
                          children: [
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: (message.senderAvatarUrl != null && message.senderAvatarUrl!.isNotEmpty)
                                        ? NetworkImage(message.senderAvatarUrl!)
                                        : null,
                                    backgroundColor: (message.senderAvatarUrl != null && message.senderAvatarUrl!.isNotEmpty)
                                        ? Colors.transparent
                                        : (isMe ? theme.colorScheme.primary.withOpacity(0.3) : Colors.grey.shade300),
                                    child: (message.senderAvatarUrl == null || message.senderAvatarUrl!.isEmpty)
                                        ? Text(
                                        avatarDisplayText,
                                        style: TextStyle(
                                            fontSize: avatarDisplayText.length > 1 ? 11 : 13,
                                            color: isMe ? theme.colorScheme.primary : Colors.black54,
                                            fontWeight: FontWeight.w500
                                        )
                                    )
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    // Use the WhatsApp style timestamp
                                    _formatTimestamp(message.timestamp),
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    textAlign: TextAlign.center,
                                    maxLines: 1, // Ensure it doesn't wrap to two lines
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  _buildMessageStatusIcon(context, message, isMe),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 11.0),
                                decoration: BoxDecoration(
                                  // Use the corrected colors
                                    color: isMe ? myBubbleColor : otherBubbleColorDefined,
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2)
                                      )
                                    ]
                                ),
                                child: Text(
                                  message.text,
                                  // Use the corrected text colors
                                  style: TextStyle(color: isMe ? myTextColor : otherTextColorDefined, fontSize: 15.5, height: 1.3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 45),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ChatInputBar(
              onSendMessage: (text) {
                chatProvider.addMessage(text);
              },
              onRecordAudio: () {
                print("UI: Start recording audio");
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Audio recording not implemented yet."), duration: Duration(seconds: 2))
                );
              },
              onSendVisual: (source) {
                print("UI: Send visual from: $source");
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sending from $source not implemented yet."), duration: Duration(seconds: 2))
                );
              },
            ),
          ],
        );
      },
    );
  }
}