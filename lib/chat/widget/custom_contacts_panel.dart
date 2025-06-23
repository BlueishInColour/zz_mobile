import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// Callbacks passed from the parent screen (ContactsScreen)
typedef ContactTapCallback = void Function(Contact contact);
typedef AiChatTapCallback = void Function();

class CustomContactsPanel extends StatefulWidget {
  final List<Contact> contacts;
  final ContactTapCallback onContactTap;
  final AiChatTapCallback onAiChatTap;

  const CustomContactsPanel({
    Key? key,
    required this.contacts,
    required this.onContactTap,
    required this.onAiChatTap,
  }) : super(key: key);

  @override
  _CustomContactsPanelState createState() => _CustomContactsPanelState();
}

class _CustomContactsPanelState extends State<CustomContactsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  final double _peekWidth = 60.0;
  final double _maxWidth = 280.0; // Your desired max width for the panel
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Ensure the animation starts from peekWidth and goes to _maxWidth
    _widthAnimation = Tween<double>(begin: _peekWidth, end: _maxWidth)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Optional: If you want the panel to be partially open by default,
    // you could initialize it here, but typically it starts closed/peeking.
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // --- Gesture Handling ---
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Allow dragging to control the panel width directly (more interactive)
    // Or keep your simpler toggle logic:
    if (!_isOpen && details.primaryDelta! > 1.0) {
      _togglePanel();
    } else if (_isOpen && details.primaryDelta! < -1.0 ) {
      _togglePanel();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    // Check if the panel is already in the target state to avoid redundant calls
    if (!_isOpen && details.primaryVelocity! > 300) {
      _togglePanel();
    } else if (_isOpen && details.primaryVelocity! < -300) {
      _togglePanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This Positioned widget assumes your panel slides from the left.
    // If ContactsScreen handles the positioning/stacking,
    // this outer Positioned might not be needed here,
    // and the panel would just be a Container with AnimatedBuilder.
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTap: () {
          // If the panel is just peeking, a tap on the gesture area should open it.
          if (!_isOpen && _widthAnimation.value < (_peekWidth + 20)) { // Give a bit more buffer
            _togglePanel();
          }
        },
        child: AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) {
            // Determine when to show full details based on current animated width
            bool showFullDetails = _widthAnimation.value > (_maxWidth * 0.6); // Example: show details when over 60% open
            bool canShowLeadingAvatar = _widthAnimation.value > (_peekWidth - 5); // Allow avatar even in peek mode
            bool showTitleText = _widthAnimation.value > (_peekWidth + 50);

            return Material(
              elevation: 8.0,
              color: Colors.transparent, // Make Material transparent if Container below has color
              child: Container(
                width: _widthAnimation.value,
                // Ensure color is set here for the actual panel background
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    // --- Panel Header / Toggle ---
                    SizedBox(
                      height: 50, // Standard height for a header/toolbar area
                      child: Stack(
                        children: [
                          // "Contacts" Title - shown when panel is wider
                          if (showTitleText)
                            Positioned.fill(
                              left: 16,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Contacts",
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          // Toggle Button (Arrow) - always visible or dynamically shown
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _togglePanel,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: _isOpen ? 16.0 : 8.0),
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  _isOpen ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                                  size: 18,
                                  // Change color based on theme
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // --- List of Contacts ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.contacts.length + 1, // +1 for AI Chat
                        itemBuilder: (context, index) {
                          // --- AI Chat Tile (First Item) ---
                          if (index == 0) {
                            return ListTile(
                              leading: canShowLeadingAvatar ? const CircleAvatar(child: Icon(Icons.smart_toy_outlined)) : null,
                              title: showFullDetails ? const Text('AI Assistant') : null,
                              subtitle: showFullDetails ? const Text("Chat with our AI") : null,
                              contentPadding: showFullDetails
                                  ? null // Default padding when open
                                  : const EdgeInsets.symmetric(horizontal: 16.0), // Center icon when closed
                              onTap: () {
                                if (_isOpen && showFullDetails) {
                                  widget.onAiChatTap();
                                } else if (!_isOpen) {
                                  _togglePanel(); // Open panel if tapped while peeking
                                }
                              },
                            );
                          }

                          // --- Regular Contact Tiles ---
                          final contactIndex = index - 1;
                          final Contact contact = widget.contacts[contactIndex];
                          String displayName = contact.displayName;
                          String firstLetter = displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : (contact.name.first.isNotEmpty
                              ? contact.name.first[0].toUpperCase()
                              : "?");

                          Widget? leadingWidget;
                          if (canShowLeadingAvatar) {
                            leadingWidget = CircleAvatar(
                              radius: 18,
                              backgroundImage: (contact.photoOrThumbnail != null)
                                  ? MemoryImage(contact.photoOrThumbnail!)
                                  : null,
                              child: (contact.photoOrThumbnail == null)
                                  ? Text(firstLetter, style: const TextStyle(fontSize: 14))
                                  : null,
                            );
                          }

                          return ListTile(
                            leading: leadingWidget,
                            title: showFullDetails ? Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                            subtitle: showFullDetails && contact.phones.isNotEmpty
                                ? Text(contact.phones.first.number, maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                            onTap: () {
                              if (_isOpen && showFullDetails) {
                                widget.onContactTap(contact);
                              } else if (!_isOpen) {
                                _togglePanel(); // Open panel if tapped while peeking
                              }
                              // If _isOpen but !showFullDetails (panel is opening/closing), tap does nothing
                            },
                            contentPadding: showFullDetails
                                ? null
                                : const EdgeInsets.symmetric(horizontal: 16.0), // Center icon when closed
                            minVerticalPadding: _widthAnimation.value < (_peekWidth + 20) ? 2 : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}