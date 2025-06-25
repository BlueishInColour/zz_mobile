// screens/glimpse_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ensure Provider is imported
import '../providers/story_provider.dart';
import '../widgets/glimpse_contacts_panel.dart';
import '../widgets/glimpse_detail_view.dart';
import '../widgets/vertical_story_progress_indicator.dart'; // <-- IMPORT THE NEW WIDGET

class GlimpseTabScreen extends StatelessWidget {
  const GlimpseTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No need to call Provider.of here if child widgets are consuming it.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glimpse'),
        // backgroundColor: Theme.of(context).canvasColor,
        // elevation: 0.5,
      ),
      body: Row(
        children: [
          const GlimpseContactsPanel(), // Your existing contacts panel

          // // --- ADD THE VERTICAL STORY PROGRESS INDICATOR HERE ---
          // // It will only build if there's an active contact with stories,
          // // thanks to the Consumer and logic within VerticalStoryProgressIndicator.
          // Consumer<StoryProvider>(
          //   builder: (context, provider, child) {
          //     // Conditionally show the indicator based on provider state
          //     if (provider.activeStoryContact != null &&
          //         provider.activeStoryContact!.stories.isNotEmpty) {
          //       return const VerticalStoryItemProgressIndicator();
          //     }
          //     // If no active contact or stories, return an empty SizedBox
          //     // so it doesn't take up space or try to build with null data.
          //     return const SizedBox.shrink();
          //   },
          // ),
          // // --- END OF VERTICAL INDICATOR ---

          const Expanded(
            child: GlimpseDetailView(), // Your existing detail view (PageView)
          ),
        ],
      ),
    );
  }
}