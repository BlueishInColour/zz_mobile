// widgets/glimpse_page_item.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/story_models.dart';
import '../providers/story_provider.dart';

class GlimpsePageItem extends StatefulWidget {
  final StoryItem storyItem;
  final StoryContact contact;
  final int totalStoriesInContact;
  final int currentStoryIndexInContact;

  const GlimpsePageItem({
    Key? key,
    required this.storyItem,
    required this.contact,
    required this.totalStoriesInContact,
    required this.currentStoryIndexInContact,
  }) : super(key: key);

  @override
  _GlimpsePageItemState createState() => _GlimpsePageItemState();
}

class _GlimpsePageItemState extends State<GlimpsePageItem>
    with SingleTickerProviderStateMixin {
  Timer? _advanceTimer;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  bool _isLikedByCurrentUser = false;
  final String _currentUserId = "currentUserDemoId"; // Replace with actual auth logic

  AnimationController? _progressAnimationController;
  Animation<double>? _progressAnimation;

  static const int _defaultImageDurationSeconds = 8;

  @override
  void initState() {
    super.initState();
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    _isLikedByCurrentUser = widget.storyItem.likedBy.contains(_currentUserId);

    _progressAnimationController = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: widget.storyItem.mediaType == MediaType.image
              ? (widget.storyItem.durationInSeconds > 0
              ? widget.storyItem.durationInSeconds
              : _defaultImageDurationSeconds)
              : _defaultImageDurationSeconds),
    );

    _progressAnimation =
    Tween<double>(begin: 0.0, end: 1.0).animate(_progressAnimationController!)
      ..addListener(() {
        if (mounted) {
          setState(() {}); // Redraw on animation frame
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted && _isThisPageActive(storyProvider)) {
            storyProvider.nextStory();
          }
        }
      });

    _conditionallyStartTimerAndAnimation(storyProvider);
    _replyFocusNode.addListener(_onReplyFocusChange);
  }

  void _onReplyFocusChange() {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    if (_replyFocusNode.hasFocus) {
      _pauseAnimationAndTimer();
    } else {
      // Only resume if the page is still active and it's an image story
      if (_isThisPageActive(storyProvider) && widget.storyItem.mediaType == MediaType.image) {
        _resumeAnimationAndTimer();
      } else {
        _conditionallyStartTimerAndAnimation(storyProvider); // Or re-evaluate
      }
    }
  }

  @override
  void didUpdateWidget(covariant GlimpsePageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);

    if (oldWidget.storyItem.id != widget.storyItem.id) {
      _isLikedByCurrentUser = widget.storyItem.likedBy.contains(_currentUserId);
      _replyController.clear(); // Clear reply on new story
      _progressAnimationController?.duration = Duration(
          seconds: widget.storyItem.mediaType == MediaType.image
              ? (widget.storyItem.durationInSeconds > 0
              ? widget.storyItem.durationInSeconds
              : _defaultImageDurationSeconds)
              : _defaultImageDurationSeconds);
      _conditionallyStartTimerAndAnimation(storyProvider);
    } else {
      // This case might be if something else forced a rebuild but the story is the same.
      // We should ensure animation continues if it's supposed to be active.
      _conditionallyStartTimerAndAnimation(storyProvider);
    }
  }

  bool _isThisPageActive(StoryProvider storyProvider) {
    return storyProvider.activeStoryContact?.userId == widget.contact.userId &&
        storyProvider.currentStoryIndexInActiveContact ==
            widget.currentStoryIndexInContact;
  }

  void _conditionallyStartTimerAndAnimation(StoryProvider storyProvider) {
    _resetAndPauseAnimationAndTimer(); // Always reset before deciding to start
    if (mounted &&
        _isThisPageActive(storyProvider) &&
        widget.storyItem.mediaType == MediaType.image &&
        !_replyFocusNode.hasFocus) {
      _startAutoAdvanceTimerAndAnimation();
    }
  }

  void _startAutoAdvanceTimerAndAnimation() {
    _cancelAdvanceTimer();
    if (widget.storyItem.mediaType == MediaType.image && mounted) {
      _progressAnimationController?.forward(from: 0.0);
    }
  }

  void _pauseAnimationAndTimer() {
    _cancelAdvanceTimer();
    _progressAnimationController?.stop();
  }

  void _resumeAnimationAndTimer() {
    if (mounted &&
        _isThisPageActive(Provider.of<StoryProvider>(context, listen: false)) &&
        widget.storyItem.mediaType == MediaType.image &&
        !_replyFocusNode.hasFocus &&
        _progressAnimationController != null &&
        !_progressAnimationController!.isCompleted &&
        !_progressAnimationController!.isAnimating) {
      _progressAnimationController!.forward();
    }
  }

  void _resetAndPauseAnimationAndTimer() {
    _cancelAdvanceTimer();
    _progressAnimationController?.reset();
  }

  void _cancelAdvanceTimer() {
    _advanceTimer?.cancel();
    _advanceTimer = null;
  }

  @override
  void dispose() {
    _cancelAdvanceTimer();
    _progressAnimationController?.dispose();
    _replyController.dispose();
    _replyFocusNode.removeListener(_onReplyFocusChange);
    _replyFocusNode.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(timestamp);
  }

  void _handleLike() {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    storyProvider.toggleLikeCurrentStory(_currentUserId);
    // Optimistic update for UI, provider will eventually update the source
    if (mounted) {
      setState(() {
        _isLikedByCurrentUser = widget.storyItem.likedBy.contains(_currentUserId);
      });
    }
  }

  void _handleSendReply() {
    if (_replyController.text.trim().isEmpty) return;
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // Actual send logic would go here (e.g., call provider method)
    print(
        "Reply: '${_replyController.text}' to ${widget.contact.displayName}'s story '${widget.storyItem.id}'");
    _replyController.clear();
    _replyFocusNode.unfocus(); // This will trigger _onReplyFocusChange to resume animation

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Reply sent (placeholder)"),
          duration: Duration(seconds: 1)),
    );
    // _conditionallyStartTimerAndAnimation(storyProvider); // No longer needed here, focus change handles it
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets; // For keyboard visibility

    // Ensure animation starts/stops correctly based on page activity
    // This logic might be redundant if didUpdateWidget and initState cover all cases,
    // but can be a safeguard.
    if (mounted && _isThisPageActive(storyProvider) &&
        _progressAnimationController != null &&
        !_progressAnimationController!.isAnimating &&
        !_progressAnimationController!.isCompleted &&
        widget.storyItem.mediaType == MediaType.image &&
        !_replyFocusNode.hasFocus) {
      _progressAnimationController!.forward();
    } else if (mounted && !_isThisPageActive(storyProvider) &&
        _progressAnimationController != null &&
        _progressAnimationController!.isAnimating) {
      _progressAnimationController!.stop();
    }

    return GestureDetector(
      onTapDown: (_) => _pauseAnimationAndTimer(),
      onTapUp: (_) => _resumeAnimationAndTimer(),
      onLongPressStart: (_) => _pauseAnimationAndTimer(),
      onLongPressEnd: (_) => _resumeAnimationAndTimer(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMediaContent(),
          // Top section: Progress, User Info
          Positioned(
            top: 12.0 + MediaQuery.of(context).padding.top, // Consider safe area
            left: 8.0,
            right: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressDashes(storyProvider),
                const SizedBox(height: 10),
                _buildUserInfoAndTime(),
              ],
            ),
          ),
          // Bottom section: Caption, Reply, Like
          Positioned(
            bottom: (viewInsets.bottom > 0 ? viewInsets.bottom : 15.0) + MediaQuery.of(context).padding.bottom, // Adjust for keyboard and safe area
            left: 15.0,
            right: 15.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaption(),
                const SizedBox(height: 12),
                _buildReplyAndLikeRow(theme, storyProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.storyItem.mediaType == MediaType.image) {
      return Image.network(
        widget.storyItem.mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
              child: CircularProgressIndicator(
                  color: Colors.white60, strokeWidth: 2.0));
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.white60, size: 60));
        },
      );
    } else {
      // Placeholder for video or other media types
      return Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_outlined,
                  color: Colors.white70, size: 60),
              const SizedBox(height: 10),
              Text(
                "Video Player for\n${widget.storyItem.mediaUrl}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildProgressDashes(StoryProvider storyProvider) {
    return Row(
      children: List.generate(widget.totalStoriesInContact, (index) {
        bool isCurrentStory = index == widget.currentStoryIndexInContact;
        bool isViewed = widget.contact.stories[index].isViewedByCurrentUser;
        Color baseDashColor;

        if (isCurrentStory) {
          baseDashColor = Colors.white.withOpacity(0.40);
        } else if (isViewed) {
          baseDashColor = Colors.white.withOpacity(0.55); // Slightly more visible for viewed
        } else {
          baseDashColor = Colors.white.withOpacity(0.25);
        }

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (index != widget.currentStoryIndexInContact) {
                // _resetAndPauseAnimationAndTimer(); // This is called by jumpToStoryInCurrentContact via provider updates
                storyProvider.jumpToStoryInCurrentContact(index);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Stack(
                children: [
                  Container(
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: baseDashColor,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  if (isCurrentStory && _progressAnimation != null)
                    FractionallySizedBox(
                      widthFactor: _progressAnimation!.value,
                      child: Container(
                        height: 3.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoAndTime() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white30,
          backgroundImage: widget.contact.avatarUrl != null &&
              widget.contact.avatarUrl!.isNotEmpty
              ? NetworkImage(widget.contact.avatarUrl!)
              : null,
          child: widget.contact.avatarUrl == null ||
              widget.contact.avatarUrl!.isEmpty
              ? Text(
            widget.contact.displayName.isNotEmpty
                ? widget.contact.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contact.displayName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
              ),
              Text(
                _formatTimestamp(widget.storyItem.timestamp),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [Shadow(blurRadius: 1, color: Colors.black45)]),
              ),
            ],
          ),
        ),
        // Placeholder for More Options Icon
        // Icon(Icons.more_vert, color: Colors.white70, size: 22),
      ],
    );
  }

  Widget _buildCaption() {
    if (widget.storyItem.caption == null ||
        widget.storyItem.caption!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.storyItem.caption!,
        style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.3),
        maxLines: 3, // Allow more lines for caption if needed
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReplyAndLikeRow(ThemeData theme, StoryProvider storyProvider) {
    int currentLikesCount = widget.storyItem.likedBy.length;

    const double likeButtonSize = 28.0;
    const double badgeDiameter = 18.0; // Diameter for a circular badge
    const double likeButtonAreaHeight = 48.0; // To ensure vertical space for badge + button

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Material(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(25),
            child: TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendReply(),
              decoration: InputDecoration(
                hintText: "Comment...", // Updated hint text
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 15),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send_rounded,
                      color: Colors.white.withOpacity(0.85), size: 22),
                  onPressed: _handleSendReply,
                  splashRadius: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Like Button and Count Area (using a Stack for badge-like positioning)
        SizedBox(
          width: likeButtonSize + badgeDiameter * 0.5, // Allow some overlap space for badge
          height: likeButtonAreaHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Like Button - centered in the Stack
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  iconSize: likeButtonSize,
                  splashRadius: likeButtonSize * 0.85,
                  padding: const EdgeInsets.all(8.0), // Consistent padding
                  icon: Icon(
                    _isLikedByCurrentUser
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isLikedByCurrentUser
                        ? theme.colorScheme.error // More prominent liked color
                        : Colors.white,
                  ),
                  onPressed: _handleLike,
                ),
              ),
              // Like Count Badge (positioned at top-right relative to the Stack center)
              if (currentLikesCount > 0)
                Positioned(
                  // Adjust these values carefully to position the badge
                  top: (likeButtonAreaHeight / 2) - // Center of stack
                      (likeButtonSize / 2) - // Offset by half button size (top of button)
                      (badgeDiameter / 2.5), // Further offset for badge overlap
                  right: 0, // Align to the right edge of the SizedBox
                  child: Container(
                    padding: const EdgeInsets.all(2), // Minimal padding inside badge
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle, // Circular badge
                      border: Border.all(
                          color: Colors.white.withOpacity(0.8), width: 1.0),
                    ),
                    constraints: BoxConstraints(
                      minWidth: badgeDiameter,
                      minHeight: badgeDiameter,
                    ),
                    child: Center(
                      child: Text(
                        currentLikesCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}