// widgets/jotter_contacts_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import '../screens/edit_jot_screen.dart';

class JotterContactsPanel extends StatefulWidget {
  final double panelWidthCollapsed;
  final double panelWidthExpanded;

  const JotterContactsPanel({
    Key? key,
    this.panelWidthCollapsed = 70.0,
    this.panelWidthExpanded = 250.0,
  }) : super(key: key);

  @override
  _JotterContactsPanelState createState() => _JotterContactsPanelState();
}

class _JotterContactsPanelState extends State<JotterContactsPanel> {
  final double _avatarRadius = 20.0;
  final double _buttonSize = 42.0;
  final double _buttonIconSizeFactor = 0.55;
  final double _buttonMargin = 8.0; // This is the one we are passing down
  final double _spaceBetweenButtons = 6.0;

  Widget _buildPanelIconButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    double? elevation,
  }) {
    return Material(
      color: backgroundColor,
      elevation: elevation ?? 1.0,
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

  @override
  Widget build(BuildContext context) {
    final jotterProvider = Provider.of<JotterProvider>(context);
    final bool isExpanded = jotterProvider.isPanelExpanded;
    final double currentWidth = isExpanded ? widget.panelWidthExpanded : widget.panelWidthCollapsed;
    final contacts = jotterProvider.contactsForPanel;
    final theme = Theme.of(context);

    Color panelBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[100]!;

    return Material(
      elevation: 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: currentWidth,
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
              child: contacts.isEmpty && jotterProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contacts.isEmpty
                  ? (isExpanded
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "No contacts with jots. Tap '+' to add one!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              )
                  : const SizedBox.shrink())
                  : ListView.builder(
                padding: EdgeInsets.only(top: _buttonMargin, bottom: _buttonMargin),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final bool isSelected = jotterProvider.selectedContact?.userId == contact.userId;
                  return _JotterContactPanelItem(
                    contact: contact,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                    avatarRadius: _avatarRadius,
                    onTap: () {
                      if (isSelected && isExpanded && jotterProvider.selectedContact?.userId == contact.userId) return;
                      jotterProvider.selectContact(contact);
                    },
                    panelWidthCollapsed: widget.panelWidthCollapsed,
                    buttonMargin: _buttonMargin, // <-- Pass _buttonMargin here
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_buttonMargin),
              child: isExpanded
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPanelButton(
                    context: context,
                    icon: Icons.add_circle_outline_rounded,
                    label: "New Jot",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditJotScreen()),
                      );
                    },
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  SizedBox(height: _spaceBetweenButtons),
                  _buildPanelButton(
                    context: context,
                    icon: Icons.chevron_left,
                    label: "Collapse Panel",
                    onPressed: jotterProvider.togglePanel,
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.85),
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ],
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPanelIconButton(
                    context: context,
                    icon: Icons.add_circle_outline_rounded,
                    tooltip: "New Jot",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditJotScreen()),
                      );
                    },
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  SizedBox(height: _spaceBetweenButtons),
                  _buildPanelIconButton(
                    context: context,
                    icon: Icons.chevron_right,
                    tooltip: "Expand Panel",
                    onPressed: jotterProvider.togglePanel,
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.85),
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JotterContactPanelItem extends StatelessWidget {
  final JotterContact contact;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final double avatarRadius;
  final double panelWidthCollapsed;
  final double buttonMargin; // <-- Field added

  const _JotterContactPanelItem({
    Key? key,
    required this.contact,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.avatarRadius = 20.0,
    required this.panelWidthCollapsed,
    required this.buttonMargin, // <-- Added to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double currentAvatarRadius = isExpanded ? avatarRadius : avatarRadius - 2;
    Color avatarBackgroundColor = theme.colorScheme.surfaceVariant;
    Color avatarForegroundColor = theme.colorScheme.onSurfaceVariant;

    Color itemBackgroundColor = Colors.transparent;
    if (isExpanded && isSelected) {
      itemBackgroundColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
    }

    Widget avatarWidget = CircleAvatar(
      radius: currentAvatarRadius,
      backgroundColor: avatarBackgroundColor,
      backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
          ? NetworkImage(contact.avatarUrl!)
          : null,
      child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
          ? Text(
        contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : "?",
        style: TextStyle(
          fontSize: currentAvatarRadius * 0.9,
          fontWeight: FontWeight.bold,
          color: avatarForegroundColor,
        ),
      )
          : null,
    );

    if (isSelected) {
      avatarWidget = Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        child: avatarWidget,
      );
    }

    if (!isExpanded) {
      double avatarTotalDiameterWithBorder = (currentAvatarRadius * 2) + (isSelected ? (1.5 * 2 + 2.0 * 2) : 0);
      double horizontalMargin = (panelWidthCollapsed - avatarTotalDiameterWithBorder) / 2;
      horizontalMargin = horizontalMargin > 0 ? horizontalMargin : buttonMargin / 2; // <-- Used passed-in buttonMargin

      return Tooltip(
        message: contact.displayName,
        preferBelow: false,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin.clamp(buttonMargin / 2, double.infinity), // Ensure a minimum margin
              vertical: buttonMargin / 1.5, // <-- Used passed-in buttonMargin
            ),
            child: avatarWidget,
          ),
        ),
      );
    }

    return Material(
      color: itemBackgroundColor,
      child: InkWell(
        onTap: onTap,
        splashColor: theme.splashColor.withOpacity(0.1),
        highlightColor: theme.highlightColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              avatarWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}