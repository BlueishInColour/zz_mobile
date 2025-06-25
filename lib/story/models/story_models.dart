// models/story_models.dart
import 'package:flutter/foundation.dart'; // For @required

enum MediaType { image, video }

class StoryItem {
  final String id;
  final String userId; // To know who posted it
  final String mediaUrl;
  final MediaType mediaType;
  final String? caption;
  final DateTime timestamp;
  final int durationInSeconds; // For auto-advance (e.g., 5 for images)
  final int likesCount;
  final List<String> likedBy; // User IDs of who liked, for client-side check
  bool isViewedByCurrentUser;

  StoryItem({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    required this.timestamp,
    this.durationInSeconds = 5, // Default for images
    this.likesCount = 0,
    this.likedBy = const [],
    this.isViewedByCurrentUser = false,
  });
}

class StoryContact {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final List<StoryItem> stories; // Sorted oldest to newest for this user

  StoryContact({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.stories,
  });

  DateTime? get lastStoryTimestamp {
    if (stories.isEmpty) return null;
    return stories.last.timestamp; // Assuming stories are sorted by time
  }

  bool get hasUnviewedStories {
    return stories.any((story) => !story.isViewedByCurrentUser);
  }

  int get unviewedStoriesCount {
    return stories.where((story) => !story.isViewedByCurrentUser).length;
  }
}

// Helper to identify a story globally for the continuous PageView
class GlobalStoryIdentifier {
  final String contactUserId;
  final String storyId;
  final int storyIndexInContact; // Index of this story within its contact's list

  GlobalStoryIdentifier({
    required this.contactUserId,
    required this.storyId,
    required this.storyIndexInContact,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GlobalStoryIdentifier &&
              runtimeType == other.runtimeType &&
              contactUserId == other.contactUserId &&
              storyId == other.storyId;

  @override
  int get hashCode => contactUserId.hashCode ^ storyId.hashCode;
}