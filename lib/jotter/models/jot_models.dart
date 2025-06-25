// models/jot_models.dart
import 'package:flutter/foundation.dart'; // For @required

// Using a simple contact model for now.
// In a real app, this would likely come from your existing contact management system.
class JotterContact {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  DateTime? lastJotActivity; // For sorting in the panel

  JotterContact({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.lastJotActivity,
  });

  // Basic equality and hashCode for provider updates
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is JotterContact &&
              runtimeType == other.runtimeType &&
              userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

enum JotMediaType { text, image, video, audio, checklist }

class JotMediaItem {
  final String id; // Unique ID for this media item
  final JotMediaType type;
  final String urlOrPath; // For image, video, audio
  String? caption; // Optional caption for media

  JotMediaItem({
    required this.id,
    required this.type,
    required this.urlOrPath,
    this.caption,
  });
}

class JotChecklistItem {
  final String id; // Unique ID for this checklist item
  String text;
  bool isChecked;

  JotChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });
}

class JotItem {
  final String id; // Unique ID for the jot
  final String contactUserId; // ID of the contact this jot is primarily associated with
  // (could be current user's ID for self-notes)
  String title;
  String? textContent; // For the main text body
  List<JotMediaItem> mediaAttachments;
  List<JotChecklistItem> checklistItems;
  DateTime createdAt;
  DateTime updatedAt;
  String? createdByUserId; // Who actually created this jot (if different from contactUserId for shared notes)

  JotItem({
    required this.id,
    required this.contactUserId,
    required this.title,
    this.textContent,
    List<JotMediaItem>? mediaAttachments,
    List<JotChecklistItem>? checklistItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
  })  : this.mediaAttachments = mediaAttachments ?? [],
        this.checklistItems = checklistItems ?? [],
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  // Helper to get a preview snippet for the masonry grid
  String get contentPreview {
    if (textContent != null && textContent!.isNotEmpty) {
      return textContent!.length > 100
          ? '${textContent!.substring(0, 100)}...'
          : textContent!;
    }
    if (mediaAttachments.isNotEmpty) {
      return "[Contains ${mediaAttachments.first.type.name}]";
    }
    if (checklistItems.isNotEmpty) {
      return "[Checklist with ${checklistItems.length} items]";
    }
    return "No additional content";
  }

  // Basic equality and hashCode for provider updates
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is JotItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}