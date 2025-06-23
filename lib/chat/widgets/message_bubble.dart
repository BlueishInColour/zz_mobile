import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
class MessageBubble extends StatelessWidget {
  final String messageText;
  final String? senderAvatarUrl;
  final String senderDisplayName;
  final DateTime timestamp;
  final MessageStatus? status; // Will likely only be shown if isMe is true
  final bool isMe; // Still needed to decide if status icon is shown & potentially other subtle cues

  const MessageBubble({
    Key? key,
    required this.messageText,
    this.senderAvatarUrl,
    required this.senderDisplayName,
    required this.timestamp,
    this.status,
    required this.isMe,
  }) : super(key: key);

  String _formatTimestamp(DateTime ts) { return "";/* ... */ }
  Widget _buildStatusIcon(MessageStatus? msgStatus, bool isSenderMe) {
    if (!isSenderMe || msgStatus == null) return SizedBox.shrink(); // Only for your messages
    // ... your status icon logic
    if (msgStatus == MessageStatus.read) return Icon(Icons.done_all, color: Colors.blue, size: 14);
    if (msgStatus == MessageStatus.delivered) return Icon(Icons.done_all, color: Colors.grey[400], size: 14); // Example color
    if (msgStatus == MessageStatus.sent) return Icon(Icons.check, color: Colors.grey[400], size: 14); // Example color
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Assuming dark theme. Get appropriate darker shade.
    // This could come from Theme.of(context) or be predefined.
    final Color screenBackgroundColor = Theme.of(context).scaffoldBackgroundColor; // Or whatever your chat screen bg is
    final Color darkerShadeColor = Color.lerp(screenBackgroundColor, Colors.black, 0.1) ?? Colors.grey[850]!; // Example: 10% darker

    const double avatarRadius = 20.0;
    const double avatarAreaHorizontalPadding = 8.0; // Padding inside the darker shade area
    final double darkerShadeWidth = (avatarRadius * 2) + (avatarAreaHorizontalPadding * 2);
    const double paddingBetweenShadeAndBubble = 8.0;

    final avatarAndTimeStatusBlock = Column(
      mainAxisSize: MainAxisSize.min, // Fit content
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundImage: senderAvatarUrl != null ? NetworkImage(senderAvatarUrl!) : null,
          child: senderAvatarUrl == null ? Text(senderDisplayName.isNotEmpty ? senderDisplayName[0].toUpperCase() : 'U') : null,
        ),
        const SizedBox(height: 6), // Space between avatar and timestamp
        Text(
          _formatTimestamp(timestamp),
          style: TextStyle(fontSize: 10, color: Colors.grey[500]), // Lighter text on darker shade
        ),
        const SizedBox(height: 2), // Space between timestamp and status
        _buildStatusIcon(status, isMe),
      ],
    );

    final darkerShadeArea = Container(
      width: darkerShadeWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical padding for the content within
      decoration: BoxDecoration(
        color: darkerShadeColor,
        // Optional: if you want this shade to have rounded corners on the right side where it meets the padding
        // borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: avatarAndTimeStatusBlock,
    );

    final bubbleContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // Neutral bubble color, perhaps slightly lighter than the darkerShade, or distinct
        color: Color.lerp(screenBackgroundColor, Colors.black, 0.05) ?? Colors.grey[800]!, // Example: 5% darker than screen for bubble
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        messageText,
        style: TextStyle(color: Colors.grey[300]), // Example text color for dark theme bubble
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Padding between message rows
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align shade area and bubble to their tops
        children: [
          darkerShadeArea,
          const SizedBox(width: paddingBetweenShadeAndBubble),
          Expanded( // Bubble takes remaining width
            child: Align( // Bubbles still align left within their expanded space
              alignment: Alignment.centerLeft,
              child: bubbleContent,
            ),
          ),
        ],
      ),
    );
  }
}