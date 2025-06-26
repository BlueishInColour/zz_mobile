// widgets/draggable_contacts_panel_for_chat.dart
import 'package:flutter/material.dart';

// Dummy Contact class (ensure you have your actual Contact model)
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
  final Function(bool)? onExpansionChanged; // <<< NEW CALLBACK

  const DraggableContactsPanelForChat({
    Key? key,
    required this.contacts,
    required this.onContactSelected,
    this.panelWidthCollapsed = 70.0,
    this.panelWidthExpanded = 250.0,
    this.isInitiallyExpanded = false,
    this.onExpansionChanged, // <<< NEW PARAMETER
  }) : super(key: key);

  @override
  _DraggableContactsPanelForChatState createState() => _DraggableContactsPanelForChatState();
}

class _DraggableContactsPanelForChatState extends State<DraggableContactsPanelForChat> {
  late bool _isExpanded;
  double _currentWidth = 0;
  // ... other variables ...

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
      widget.onExpansionChanged?.call(_isExpanded); // <<< CALL THE CALLBACK
    });
  }

  // ... rest of the widget build method ...
  // (No changes needed in the build method of DraggableContactsPanelForChat for this specific fix)
  @override
  Widget build(BuildContext context) {
    Color panelBackgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[100]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _currentWidth,
      decoration: BoxDecoration(
        color: panelBackgroundColor,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: widget.panelWidthCollapsed > 0 ? 40.0 + 8.0 * 2 : 8.0, // Space for button
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8.0),
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
                        _toggleExpand();
                        // widget.onContactSelected(contact); // Optionally select immediately after expand
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: _isExpanded ? 10.0 : 8.0 / 2,
                        horizontal: _isExpanded ? 16.0 : 8.0,
                      ),
                      height: _isExpanded ? null : (20.0 * 2) + (8.0 * 2),
                      child: Align(
                        alignment: _isExpanded ? Alignment.centerLeft : Alignment.center,
                        child: _isExpanded
                            ? Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
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
                            : Tooltip(
                          message: contact.displayName,
                          child: CircleAvatar(
                            radius: 20.0,
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
          if (widget.panelWidthCollapsed > 0) // Only show button if there's a collapsed state
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: 8.0,
              left: _isExpanded ? null : (_currentWidth - 40.0) / 2,
              right: _isExpanded ? 8.0 : null,
              child: Material(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                elevation: 2,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                      size: 40.0 * 0.5,
                    ),
                    color: Theme.of(context).colorScheme.onSecondary,
                    onPressed: _toggleExpand,
                    splashRadius: 40.0 / 2,
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