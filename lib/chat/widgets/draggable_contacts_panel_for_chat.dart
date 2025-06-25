// widgets/draggable_contacts_panel_for_chat.dart
import 'package:flutter/material.dart';

// Dummy Contact class for example (ensure you have your actual Contact model)
class Contact {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isAi;

  Contact({required this.id, required this.displayName, this.avatarUrl, this.isAi = false});
}

class DraggableContactsPanelForChat extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;
  final double panelWidthCollapsed;
  final double panelWidthExpanded;
  final bool isInitiallyExpanded;

  const DraggableContactsPanelForChat({
    Key? key,
    required this.contacts,
    required this.onContactSelected,
    this.panelWidthCollapsed = 70.0, // Adjusted default
    this.panelWidthExpanded = 250.0,
    this.isInitiallyExpanded = false,
  }) : super(key: key);

  @override
  _DraggableContactsPanelForChatState createState() => _DraggableContactsPanelForChatState();
}

class _DraggableContactsPanelForChatState extends State<DraggableContactsPanelForChat> {
  late bool _isExpanded;
  double _currentWidth = 0;
  final double _avatarRadius = 20.0; // Slightly increased for better visibility
  final double _collapsedPadding = 8.0;
  final double _buttonSize = 40.0; // Size of the toggle button
  final double _buttonMargin = 8.0; // Margin for the button from panel edges

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
    _currentWidth = _isExpanded ? widget.panelWidthExpanded : widget.panelWidthCollapsed;
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _currentWidth = _isExpanded ? widget.panelWidthExpanded : widget.panelWidthCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color panelBackgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[100]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _currentWidth,
      decoration: BoxDecoration( // Use decoration for better control over background and potential borders
        color: panelBackgroundColor,
        // Optional: Add a subtle border if you want to distinguish it from the background
        // border: Border(
        //   right: BorderSide(
        //     color: Theme.of(context).dividerColor.withOpacity(0.5),
        //     width: 1.0,
        //   ),
        // ),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow button to potentially overflow slightly if needed, though usually not
        children: [
          // Content of the panel (ListView of contacts)
          Positioned.fill(
            bottom: _buttonSize + _buttonMargin, // Leave space for the button at the bottom
            child: ListView.builder(
              padding: EdgeInsets.only(top: _buttonMargin), // Add some top padding if button is near top items
              itemCount: widget.contacts.length,
              itemBuilder: (context, index) {
                final contact = widget.contacts[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Theme.of(context).splashColor.withOpacity(0.1),
                    highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
                    onTap: () {
                      if (_isExpanded) {
                        widget.onContactSelected(contact);
                      } else {
                        // When collapsed, tapping a contact avatar could also expand the panel
                        _toggleExpand();
                        // Optionally, you could also select the contact after expanding
                        // Future.delayed(const Duration(milliseconds: 260), () {
                        //   widget.onContactSelected(contact);
                        // });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: _isExpanded ? 10.0 : _collapsedPadding / 2, // Reduced vertical padding for collapsed
                        horizontal: _isExpanded ? 16.0 : _collapsedPadding,
                      ),
                      // Fixed height for collapsed items to ensure consistency
                      height: _isExpanded ? null : (_avatarRadius * 2) + (_collapsedPadding * 2),
                      child: Align(
                        alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
                        child: _isExpanded
                            ? Row(
                          children: [
                            CircleAvatar(
                              radius: _avatarRadius,
                              backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
                              child: contact.avatarUrl == null ? Text(contact.displayName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)) : null,
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                contact.displayName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                            : Tooltip( // Add tooltip for collapsed view
                          message: contact.displayName,
                          child: CircleAvatar(
                            radius: _avatarRadius,
                            backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
                            child: contact.avatarUrl == null ? Text(contact.displayName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)) : null,
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // REMOVED the old GestureDetector for dragging and the black line Container

          // NEW Toggle Button Positioning
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: _buttonMargin,
            // Align to center when collapsed, to right when expanded
            left: _isExpanded ? null : (_currentWidth - _buttonSize) / 2,
            right: _isExpanded ? _buttonMargin : null,
            child: Material(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              elevation: 2,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: _buttonSize,
                height: _buttonSize,
                child: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                    size: _buttonSize * 0.5, // Make icon proportional to button
                  ),
                  color: Theme.of(context).colorScheme.onSecondary,
                  onPressed: _toggleExpand,
                  splashRadius: _buttonSize / 2,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: _isExpanded ? "Collapse Panel" : "Expand Panel",
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}