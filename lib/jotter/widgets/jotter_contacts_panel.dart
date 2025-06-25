// widgets/jotter_contacts_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import '../screens/jotter_contact_selection_screen.dart';
// Import your EditJotScreen if you want the add button here to directly go there
// import '../screens/edit_jot_screen.dart';

class JotterContactsPanel extends StatelessWidget {
  const JotterContactsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jotterProvider = Provider.of<JotterProvider>(context);
    final contacts = jotterProvider.contactsForPanel; // Getter handles sorting

    // Determine the width of the panel
    double panelWidth = MediaQuery.of(context).size.width * 0.3; // Example: 30% of screen width
    if (panelWidth < 200) panelWidth = 200; // Minimum width
    if (panelWidth > 350) panelWidth = 350; // Maximum width


    return Material(
      elevation: 2.0,
      child: Container(
        width: panelWidth,
        color: Theme.of(context).canvasColor.withAlpha(245), // Slightly different from scaffold background
        child: Column(
          children: [
            Expanded(
              child: contacts.isEmpty && jotterProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contacts.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "No contacts with jots yet. Start by adding a jot for yourself!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final bool isSelected = jotterProvider.selectedContact?.userId == contact.userId;
                  return _ContactPanelItem(
                    contact: contact,
                    isSelected: isSelected,
                    onTap: () {
                      jotterProvider.selectContact(contact);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // --- Bottom Action Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.group_add_outlined, size: 20),
                    label: const Text("Jot For..."), // "Jot For..." or "Add Jot"
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JotterContactSelectionScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      jotterProvider.isPanelExpanded
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                      size: 22,
                    ),
                    tooltip: jotterProvider.isPanelExpanded ? "Collapse Panel" : "Expand Panel",
                    onPressed: () {
                      jotterProvider.togglePanel();
                    },
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

class _ContactPanelItem extends StatelessWidget {
  final JotterContact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactPanelItem({
    Key? key,
    required this.contact,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Theme.of(context).highlightColor : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                    ? NetworkImage(contact.avatarUrl!)
                    : null,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
                    ? Text(
                  contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : "?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  contact.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Optional: Unread count or last activity indicator
            ],
          ),
        ),
      ),
    );
  }
}