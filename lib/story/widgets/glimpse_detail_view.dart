// widgets/glimpse_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import 'glimpse_page_item.dart';

class GlimpseDetailView extends StatelessWidget {
  const GlimpseDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This correctly listens to changes in StoryProvider,
    // so the view will rebuild if isLoading, globalStoryFeed, or activeStoryContact changes.
    final storyProvider = Provider.of<StoryProvider>(context);

    if (storyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // This state implies that after loading, there's absolutely nothing to show from any contact.
    if (storyProvider.globalStoryFeed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No Glimpses to show right now.\nTap the camera icon in the panel to add yours!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    // This state implies there are stories globally, but no specific contact's story is "active"
    // for the PageView to start with. The VerticalStoryProgressIndicator also relies on an activeContact.
    if (storyProvider.activeStoryContact == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Select a contact from the panel to view their Glimpses.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    // If we've passed the above checks, it means:
    // 1. Not loading.
    // 2. There are stories in the global feed.
    // 3. There is an active contact selected.
    // So, we can safely build the PageView.
    return Container(
      color: Colors.black, // Background for the story view area
      child: PageView.builder(
        controller: storyProvider.pageController, // Crucial for syncing with provider
        scrollDirection: Axis.vertical, // Ensure this matches your desired interaction
        itemCount: storyProvider.globalStoryFeed.length, // Sourced from provider
        onPageChanged: storyProvider.onPageChanged, // Crucial for updating provider state
        itemBuilder: (context, globalIndex) {
          // Determine the contact and story for this globalIndex
          final globalId = storyProvider.globalStoryFeed[globalIndex];

          // Assuming contactsWithStories is kept consistent with globalStoryFeed
          // and globalId.contactUserId will always be found.
          final contact = storyProvider.contactsWithStories
              .firstWhere((c) => c.userId == globalId.contactUserId);

          // Assuming globalId.storyIndexInContact is always valid for the contact.
          final storyItem = contact.stories[globalId.storyIndexInContact];

          return GlimpsePageItem(
            key: ValueKey(storyItem.id), // Important for PageView state management
            storyItem: storyItem,
            contact: contact, // Pass the contact for name/avatar on page
            totalStoriesInContact: contact.stories.length,
            currentStoryIndexInContact: globalId.storyIndexInContact, // For progress within GlimpsePageItem
          );
        },
      ),
    );
  }
}