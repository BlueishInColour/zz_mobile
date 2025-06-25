// widgets/glimpse_contacts_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../models/story_models.dart';
import 'camera_capture_screen_placeholder.dart'; // Placeholder

class GlimpseContactsPanel extends StatefulWidget {
  const GlimpseContactsPanel({Key? key}) : super(key: key);

  @override
  _GlimpseContactsPanelState createState() => _GlimpseContactsPanelState();
}

class _GlimpseContactsPanelState extends State<GlimpseContactsPanel> {
  bool _isExpanded = false;
  double _currentWidth = 70.0;
  final double _panelWidthCollapsed = 70.0;
  final double _panelWidthExpanded = 250.0;

  final double _buttonSize = 42.0;
  final double _buttonIconSizeFactor = 0.55;
  final double _buttonMargin = 8.0;
  final double _spaceBetweenButtons = 6.0;

  void _togglePanelExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _currentWidth = _isExpanded ? _panelWidthExpanded : _panelWidthCollapsed;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentWidth = _isExpanded ? _panelWidthExpanded : _panelWidthCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: Make sure StoryProvider is listened to here for activeContact changes
    final storyProvider = Provider.of<StoryProvider>(context);
    final contacts = storyProvider.contactsWithStories;
    // activeContactId is already correctly fetched:
    // final activeContactId = storyProvider.activeStoryContact?.userId;
    final theme = Theme.of(context);

    Color panelBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[100]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: _currentWidth,
      decoration: BoxDecoration(
        color: panelBackgroundColor,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: contacts.isEmpty && !storyProvider.isLoading
                ? _isExpanded
                ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "No Glimpses yet. Tap the camera to add yours!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                  ),
                ))
                : const SizedBox.shrink()
                : ListView.builder(
              padding: EdgeInsets.only(
                  top: _buttonMargin, bottom: _buttonMargin),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                // `isSelected` is now the primary flag for the active contact indicator
                final bool isSelectedAsActive = storyProvider.activeStoryContact?.userId == contact.userId;
                return _buildContactItem(context, contact, isSelectedAsActive, storyProvider);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_buttonMargin),
            child: _isExpanded
                ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPanelButton(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  label: "Add Glimpse",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const CameraCaptureScreenPlaceholder()));
                  },
                  backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.9),
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                SizedBox(height: _spaceBetweenButtons),
                _buildPanelButton(
                  context: context,
                  icon: Icons.chevron_left,
                  label: "Collapse Panel",
                  onPressed: _togglePanelExpand,
                  backgroundColor:
                  theme.colorScheme.secondary.withOpacity(0.85),
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPanelIconButton(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  tooltip: "Add Glimpse",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const CameraCaptureScreenPlaceholder()));
                  },
                  backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.9),
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                SizedBox(height: _spaceBetweenButtons),
                _buildPanelIconButton(
                  context: context,
                  icon: Icons.chevron_right,
                  tooltip: "Expand Panel",
                  onPressed: _togglePanelExpand,
                  backgroundColor:
                  theme.colorScheme.secondary.withOpacity(0.85),
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: _buttonSize * _buttonIconSizeFactor * 0.9),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(double.infinity, _buttonSize),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildPanelIconButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Material(
      color: backgroundColor,
      elevation: 1,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, size: _buttonSize * _buttonIconSizeFactor),
        tooltip: tooltip,
        color: foregroundColor,
        onPressed: onPressed,
        iconSize: _buttonSize * _buttonIconSizeFactor,
        splashRadius: _buttonSize / 1.8,
        constraints: BoxConstraints.tight(Size(_buttonSize, _buttonSize)),
      ),
    );
  }

  // --- MODIFIED _buildContactItem ---
  Widget _buildContactItem(BuildContext context, StoryContact contact, bool isActuallyViewing, StoryProvider storyProvider) {
    final double avatarRadius = _isExpanded ? 22.0 : 20.0;
    final bool hasUnviewed = contact.hasUnviewedStories; // Keep this for unviewed story ring
    final theme = Theme.of(context);

    // Define border properties for the "currently viewing" indicator
    Color viewingIndicatorColor = theme.colorScheme.secondary; // Or any color you prefer, e.g., Colors.blueAccent
    double viewingIndicatorWidth = 2.5;

    Widget avatarWidget = CircleAvatar(
      radius: avatarRadius,
      backgroundColor: theme.colorScheme.surfaceVariant,
      backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
          ? NetworkImage(contact.avatarUrl!)
          : null,
      child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
          ? Text(
        contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
        style: TextStyle(fontSize: avatarRadius * 0.9, color: theme.colorScheme.onSurfaceVariant),
      )
          : null,
    );

    // 1. Wrap with "currently viewing" indicator if applicable (highest priority)
    if (isActuallyViewing) {
      avatarWidget = Container(
        padding: EdgeInsets.all(viewingIndicatorWidth - 0.5), // Padding to make the inner avatar seem inset
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: viewingIndicatorColor,
            width: viewingIndicatorWidth,
          ),
          // Optional: Add a subtle glow for the active viewing contact
          boxShadow: [
            BoxShadow(
              color: viewingIndicatorColor.withOpacity(0.5),
              blurRadius: 4.0,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: avatarWidget, // The original avatar goes inside this bordered container
      );
    }
    // 2. Else, if not currently viewing BUT has unviewed stories, show unviewed ring
    else if (hasUnviewed) {
      avatarWidget = Container(
        padding: const EdgeInsets.all(2.0), // Keep existing padding for unviewed ring
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary, // Color for unviewed stories
            width: 2.2,
          ),
        ),
        child: avatarWidget, // The original avatar goes inside this bordered container
      );
    }
    // If neither (not viewing and no unviewed stories), avatarWidget remains the plain CircleAvatar

    if (!_isExpanded) {
      return Tooltip(
        message: contact.displayName,
        preferBelow: false,
        child: InkWell(
          onTap: () => storyProvider.selectContact(contact),
          customBorder: const CircleBorder(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: _buttonMargin / 1.2),
            // Centering the avatar when collapsed. Adjust padding if the new border changes size.
            // The outer border effectively increases the avatar's visual size.
            margin: EdgeInsets.symmetric(horizontal: (_currentWidth - (avatarRadius * 2 + (isActuallyViewing ? (viewingIndicatorWidth * 2) : (hasUnviewed ? 5 : 0)))) / 2),
            decoration: BoxDecoration(
              // Use a subtle background for the item if it's the one being viewed,
              // distinct from the avatar's direct border.
              color: isActuallyViewing ? theme.colorScheme.secondaryContainer.withOpacity(0.3) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: avatarWidget, // Use the (potentially wrapped) avatarWidget
          ),
        ),
      );
    }

    // Expanded contact item
    return Material(
      // Use a more prominent highlight for the row if this contact is being viewed
      color: isActuallyViewing ? theme.colorScheme.secondaryContainer.withOpacity(0.35) : ( hasUnviewed ? theme.highlightColor.withOpacity(0.1) : Colors.transparent),
      child: InkWell(
        onTap: () => storyProvider.selectContact(contact),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _buttonMargin * 1.5, vertical: _buttonMargin * 1.2),
          child: Row(
            children: [
              avatarWidget, // Use the (potentially wrapped) avatarWidget
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isActuallyViewing ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14.5,
                    color: isActuallyViewing ? viewingIndicatorColor : null, // Optionally change text color too
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Keep the unviewed stories count bubble if you still want it,
              // even if the avatar has a ring for unviewed.
              // Or, you could remove this if the ring is sufficient.
              if (hasUnviewed && !isActuallyViewing) // Only show count if not the active one (to avoid clutter)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    contact.unviewedStoriesCount.toString(),
                    style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}