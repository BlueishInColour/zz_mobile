// widgets/vertical_story_item_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../models/story_models.dart'; // For StoryItem and MediaType

class VerticalStoryItemProgressIndicator extends StatefulWidget {
  const VerticalStoryItemProgressIndicator({Key? key}) : super(key: key);

  @override
  _VerticalStoryItemProgressIndicatorState createState() =>
      _VerticalStoryItemProgressIndicatorState();
}

class _VerticalStoryItemProgressIndicatorState
    extends State<VerticalStoryItemProgressIndicator>
    with SingleTickerProviderStateMixin { //Ticker for image story durations
  AnimationController? _imageProgressController;
  Animation<double>? _progressAnimation;

  // Ideally, for video, you'd get progress from your video player controller

  @override
  void initState() {
    super.initState();
    // Initialize the controller but don't start it yet.
    // The duration will be set when a story becomes active.
    _imageProgressController = AnimationController(
      vsync: this,
      // Duration will be set dynamically
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_imageProgressController!)
      ..addListener(() {
        setState(() {}); // Redraw on animation tick
      });

    // Listen to story changes from the provider to update progress
    // We'll do this using didChangeDependencies and a listener on the provider
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to changes in the current story item from the provider
    // This is a common pattern to react to provider changes affecting local state.
    final storyProvider = Provider.of<StoryProvider>(context);
    _updateProgressForStory(storyProvider.currentStoryItem);

    // Add a listener to the provider itself if more fine-grained control is needed
    // storyProvider.addListener(_handleProviderChange);
  }

  void _handleProviderChange() {
    // This is an alternative to checking in didChangeDependencies
    // if you need more complex logic on provider updates.
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    _updateProgressForStory(storyProvider.currentStoryItem);
  }


  void _updateProgressForStory(StoryItem? storyItem) {
    if (storyItem == null) {
      _imageProgressController?.stop();
      _imageProgressController?.value = 0;
      return;
    }

    if (storyItem.mediaType == MediaType.image) {
      _imageProgressController?.stop();
      _imageProgressController?.reset();
      _imageProgressController?.duration = Duration(seconds: storyItem.durationInSeconds);
      _imageProgressController?.forward()?.whenCompleteOrCancel(() {
        // When image story duration is complete, tell the provider to go to the next story
        // Ensure provider is available and widget is mounted
        if (mounted) {
          Provider.of<StoryProvider>(context, listen: false).nextStory();
        }
      });
    } else if (storyItem.mediaType == MediaType.video) {
      _imageProgressController?.stop(); // Stop image timer if a video is shown
      _imageProgressController?.value = 0;
      // For video, you would typically get progress updates from your video player
      // and update a separate value, or feed it into _imageProgressController.
      // For now, we'll just show 0 progress for video in this example.
      // Example: videoPlayerController.addListener(_updateVideoProgress);
    }
  }

  // Example: void _updateVideoProgress() {
  //   if (!mounted || videoPlayerController.value.duration == Duration.zero) return;
  //   final progress = videoPlayerController.value.position.inMilliseconds /
  //                    videoPlayerController.value.duration.inMilliseconds;
  //   _imageProgressController?.value = progress; // Or use a separate state variable
  //   if (progress >= 1.0) {
  //        Provider.of<StoryProvider>(context, listen: false).nextStory();
  //   }
  // }


  @override
  void dispose() {
    _imageProgressController?.dispose();
    // storyProvider.removeListener(_handleProviderChange); // If listener was added
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context); // To get the current story
    final currentStory = storyProvider.currentStoryItem;

    if (currentStory == null) {
      return const SizedBox.shrink(); // Don't show if no active story
    }

    double progressValue = 0.0;
    if (currentStory.mediaType == MediaType.image && _progressAnimation != null) {
      progressValue = _progressAnimation!.value;
    }
    // else if (currentStory.mediaType == MediaType.video) {
    //   progressValue = _getVideoPlayerProgress(); // From your video player state
    // }

    // If progress is effectively 0 or 1, and it's not indeterminate,
    // some progress indicators might look better with a slight minimum value if not fully empty.
    // However, for precise start/end, 0.0 to 1.0 is correct.

    return Container(
      width: 20, // Width of the container for the vertical progress bar
      padding: const EdgeInsets.symmetric(vertical: 20.0), // Give it some breathing room
      child: Center( // Center the RotatedBox
        child: RotatedBox(
          quarterTurns: 3, // Rotate -90 degrees (or 1 for +90) to make it vertical, filling bottom-to-top
          child: LinearProgressIndicator(
            value: progressValue, // This will be driven by the animation or video player
            backgroundColor: Colors.grey.shade700.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            minHeight: 10, // This is actually the "width" of the bar before rotation
          ),
        ),
      ),
    );
  }
}