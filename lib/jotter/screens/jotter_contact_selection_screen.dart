// screens/jotter_contact_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import 'edit_jot_screen.dart'; // Ensure EditJotScreen is ready to receive preselectedContactId

class JotterContactSelectionScreen extends StatelessWidget {
  const JotterContactSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We can directly use the contactsForPanel from the provider.
    // It already includes "My Jots" (or your preferred term) and other contacts.
    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);

    // contactsForPanel already has "My Jots" correctly formatted.
    // We might want to customize the "My Jots" display name specifically for this screen.
    final List<JotterContact> availableContacts = jotterProvider.contactsForPanel.map((contact) {
      if (contact.userId == jotterProvider.currentUserId) {
        // Customize the display name for the "My Jots" entry on this selection screen
        return JotterContact(
          userId: contact.userId,
          displayName: "For Myself (My Jots)", // More descriptive for selection
          avatarUrl: contact.avatarUrl, // Keep the avatar
          // any other properties if needed
        );
      }
      return contact;
    }).toList();

    // If you want to sort them alphabetically (optional, "My Jots" will be sorted too unless handled)
    // availableContacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    // If you want "My Jots (For Myself)" to always be at the top after sorting others:
    // final selfContact = availableContacts.firstWhere((c) => c.userId == jotterProvider.currentUserId);
    // availableContacts.removeWhere((c) => c.userId == jotterProvider.currentUserId);
    // availableContacts.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    // availableContacts.insert(0, selfContact);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Jot For..."),
        elevation: 0.5,
      ),
      body: Consumer<JotterProvider>( // Use Consumer if you need to react to provider changes
        builder: (context, provider, child) {
          if (provider.isLoading && availableContacts.isEmpty) { // Show loading only if initial list is empty
            return const Center(child: CircularProgressIndicator());
          }
          if (availableContacts.isEmpty) {
            return const Center(child: Text("No contacts available."));
          }

          return ListView.separated(
            itemCount: availableContacts.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16), // Visual separator
            itemBuilder: (context, index) {
              final contact = availableContacts[index];
              final bool isSelf = contact.userId == provider.currentUserId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                      ? NetworkImage(contact.avatarUrl!)
                      : null,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Added background color
                  child: (contact.avatarUrl == null || contact.avatarUrl!.isEmpty)
                      ? Text(
                    contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : "?",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer), // Added text color
                  )
                      : null,
                ),
                title: Text(contact.displayName),
                subtitle: isSelf ? const Text("Jots for your personal use") : null, // Optional subtitle for clarity
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Adjust padding
                onTap: () {
                  // Pop this selection screen first
                  Navigator.pop(context);

                  // Then navigate to EditJotScreen, passing the preselectedContactId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditJotScreen(
                        // Pass the selected contact's ID so the new jot is associated with them
                        preselectedContactId: contact.userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}