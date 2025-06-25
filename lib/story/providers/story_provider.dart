// providers/story_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/story_models.dart'; // Assuming models are in 'models' directory

class StoryProvider with ChangeNotifier {
  List<StoryContact> _contactsWithStories = [];
  List<GlobalStoryIdentifier> _globalStoryFeed = [];

  StoryContact? _activeStoryContact;
  int _currentStoryIndexInActiveContact = 0; // Index within the _activeStoryContact's stories
  int _currentGlobalPageIndex = 0; // Index in the _globalStoryFeed

  bool _isLoading = false;
  PageController pageController = PageController();

  // --- Getters ---
  List<StoryContact> get contactsWithStories => _contactsWithStories;
  List<GlobalStoryIdentifier> get globalStoryFeed => _globalStoryFeed;
  StoryContact? get activeStoryContact => _activeStoryContact;
  int get currentStoryIndexInActiveContact => _currentStoryIndexInActiveContact;
  int get currentGlobalPageIndex => _currentGlobalPageIndex;
  bool get isLoading => _isLoading;

  StoryItem? get currentStoryItem {
    if (_activeStoryContact == null ||
        _activeStoryContact!.stories.isEmpty ||
        _currentStoryIndexInActiveContact < 0 ||
        _currentStoryIndexInActiveContact >= _activeStoryContact!.stories.length) {
      return null;
    }
    return _activeStoryContact!.stories[_currentStoryIndexInActiveContact];
  }

  StoryProvider() {
    fetchStories();
  }

  Future<void> fetchStories() async {
    _isLoading = true;
    notifyListeners();

    // --- DUMMY DATA ---
    // In a real app, fetch from your backend and filter by 24hr lifespan
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final now = DateTime.now();
    _contactsWithStories = [
      StoryContact(
        userId: 'user1',
        displayName: 'Alice Wonderland',
        avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
        stories: [
          StoryItem(id: 's1a', userId: 'user1', mediaUrl: 'https://picsum.photos/seed/a1/720/1280', mediaType: MediaType.image, caption: 'Beautiful sunset!', timestamp: now.subtract(const Duration(hours: 2)), durationInSeconds: 7, likesCount: 10, likedBy: ['user2']),
          StoryItem(id: 's1b', userId: 'user1', mediaUrl: 'https://picsum.photos/seed/a2/720/1280', mediaType: MediaType.image, caption: 'Lunch time 🍕', timestamp: now.subtract(const Duration(hours: 1)), likesCount: 5),
        ],
      ),
      StoryContact(
        userId: 'user2',
        displayName: 'Bob The Builder',
        avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        stories: [
          StoryItem(id: 's2a', userId: 'user2', mediaUrl: 'https://picsum.photos/seed/b1/720/1280', mediaType: MediaType.image, timestamp: now.subtract(const Duration(minutes: 30)), isViewedByCurrentUser: true, likesCount: 2),
          StoryItem(id: 's2b', userId: 'user2', mediaUrl: 'https://picsum.photos/seed/b2/720/1280', mediaType: MediaType.image, caption: 'New project setup', timestamp: now.subtract(const Duration(minutes: 15)), likesCount: 8, likedBy: ['user1', 'user3']),
          StoryItem(id: 's2c', userId: 'user2', mediaUrl: 'https://picsum.photos/seed/b3/720/1280', mediaType: MediaType.image, caption: 'Almost done!', timestamp: now.subtract(const Duration(minutes: 5))),
        ],
      ),
      StoryContact(
        userId: 'user3',
        displayName: 'Charlie Chaplin',
          avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
         stories: [
          StoryItem(id: 's3a', userId: 'user3', mediaUrl: 'https://picsum.photos/seed/c1/720/1280', mediaType: MediaType.image, caption: 'Morning walk', timestamp: now.subtract(const Duration(hours: 5))),
        ],
      ),
      StoryContact(
        userId: 'user4_no_stories',
        displayName: 'David Empty',
        avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
        stories: [], // This contact has no stories
      ),
    ];

    // Filter stories older than 24 hours (Backend should ideally do this)
    _contactsWithStories.forEach((contact) {
      contact.stories.removeWhere((story) => story.timestamp.isBefore(now.subtract(const Duration(hours: 24))));
    });
    // Remove contacts with no stories after filtering
    _contactsWithStories.removeWhere((contact) => contact.stories.isEmpty);


    // Sort contacts by the timestamp of their newest story (most recent first)
    _contactsWithStories.sort((a, b) {
      if (a.lastStoryTimestamp == null && b.lastStoryTimestamp == null) return 0;
      if (a.lastStoryTimestamp == null) return 1; // Contacts without stories go to the end
      if (b.lastStoryTimestamp == null) return -1;
      return b.lastStoryTimestamp!.compareTo(a.lastStoryTimestamp!);
    });

    _buildGlobalStoryFeed();
    _isLoading = false;

    // If there are stories, set the first one as active
    if (_globalStoryFeed.isNotEmpty) {
      _setActiveStoryByGlobalIndex(0, fromUserInteraction: false);
    }
    notifyListeners();
  }

  void _buildGlobalStoryFeed() {
    _globalStoryFeed.clear();
    for (var contact in _contactsWithStories) {
      for (int i = 0; i < contact.stories.length; i++) {
        _globalStoryFeed.add(GlobalStoryIdentifier(
          contactUserId: contact.userId,
          storyId: contact.stories[i].id,
          storyIndexInContact: i,
        ));
      }
    }
  }

  void _setActiveStoryByGlobalIndex(int globalIndex, {bool fromUserInteraction = true}) {
    if (globalIndex < 0 || globalIndex >= _globalStoryFeed.length) return;

    _currentGlobalPageIndex = globalIndex;
    final globalId = _globalStoryFeed[globalIndex];
    final newActiveContact = _contactsWithStories.firstWhere((c) => c.userId == globalId.contactUserId);

    if (_activeStoryContact?.userId != newActiveContact.userId) {
      _activeStoryContact = newActiveContact;
    }
    _currentStoryIndexInActiveContact = globalId.storyIndexInContact;

    // Mark as viewed
    if (_activeStoryContact != null &&
        _currentStoryIndexInActiveContact < _activeStoryContact!.stories.length) {
      final story = _activeStoryContact!.stories[_currentStoryIndexInActiveContact];
      if (!story.isViewedByCurrentUser) {
        story.isViewedByCurrentUser = true;
        // In a real app, you might want to notify the backend too
      }
    }

    if (fromUserInteraction && pageController.hasClients && pageController.page?.round() != globalIndex) {
      // Animate if the change is from user tapping panel/dashes
      Future.microtask(() => pageController.animateToPage(
        globalIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ));
    } else if (!fromUserInteraction && pageController.hasClients && pageController.page?.round() != globalIndex) {
      // Jump if the change is programmatic (e.g. initial load, auto-advance)
      Future.microtask(() => pageController.jumpToPage(globalIndex));
    }


    notifyListeners();
  }

  // Called when user taps a contact in the panel
  void selectContact(StoryContact contact) {
    int firstGlobalIndexOfContact = _globalStoryFeed.indexWhere((gsi) => gsi.contactUserId == contact.userId);
    if (firstGlobalIndexOfContact != -1) {
      _setActiveStoryByGlobalIndex(firstGlobalIndexOfContact);
    }
  }

  // Called when PageView changes page
  void onPageChanged(int globalIndex) {
    if (_currentGlobalPageIndex == globalIndex) return; // Avoid redundant calls
    _setActiveStoryByGlobalIndex(globalIndex, fromUserInteraction: false);
  }

  // Called when user taps a progress dash
  void jumpToStoryInCurrentContact(int storyIndexInContact) {
    if (_activeStoryContact == null) return;
    int globalIndex = _globalStoryFeed.indexWhere((gsi) =>
    gsi.contactUserId == _activeStoryContact!.userId &&
        gsi.storyIndexInContact == storyIndexInContact);

    if (globalIndex != -1) {
      _setActiveStoryByGlobalIndex(globalIndex);
    }
  }

  void nextStory() {
    if (_currentGlobalPageIndex < _globalStoryFeed.length - 1) {
      _currentGlobalPageIndex++;
      _setActiveStoryByGlobalIndex(_currentGlobalPageIndex, fromUserInteraction: false);
    }
  }

  void previousStory() { // Less common for vertical auto-advance but good for dash tapping
    if (_currentGlobalPageIndex > 0) {
      _currentGlobalPageIndex--;
      _setActiveStoryByGlobalIndex(_currentGlobalPageIndex, fromUserInteraction: false);
    }
  }

  void toggleLikeCurrentStory(String currentUserId) {
    final story = currentStoryItem;
    if (story == null) return;

    if (story.likedBy.contains(currentUserId)) {
      story.likedBy.remove(currentUserId);
      // story.likesCount--; // Backend should handle this consistency
    } else {
      story.likedBy.add(currentUserId);
      // story.likesCount++; // Backend should handle this consistency
    }
    // Simulate likesCount update for UI, backend is source of truth
    // This is a simplification. Usually likesCount comes from backend.
    // For now, we just use likedBy.length as a proxy on client.

    notifyListeners();
    // In a real app, call backend API to update like status
  }
}