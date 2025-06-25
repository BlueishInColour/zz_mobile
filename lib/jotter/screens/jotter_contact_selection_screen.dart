// screens/jotter_contact_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import 'edit_jot_screen.dart';

class JotterContactSelectionScreen extends StatelessWidget {
  const JotterContactSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd fetch a more comprehensive list of contacts.
    // Here, we'll just use the ones already loaded in JotterProvider for simplicity,
    // plus the "My Jots" option.
    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);
    final List<JotterContact> availableContacts = [
      JotterContact(userId: jotterProvider.currentUserId, displayName: "My Jots (For Myself)"),
      ...jotterProvider.contactsForPanel.where((c) => c.userId != jotterProvider.currentUserId) // Exclude duplicate "My Jots"
    ];


    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contact for Jot"),
      ),
      body: ListView.builder(
        itemCount: availableContacts.length,
        itemBuilder: (context, index) {
          final contact = availableContacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                  ? NetworkImage(contact.avatarUrl!)
                  : null,
              child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
                  ? Text(contact.displayName[0].toUpperCase())
                  : null,
            ),
            title: Text(contact.displayName),
            onTap: () {
              // Set this contact as the one to associate the new jot with
              // Then navigate to EditJotScreen
              Navigator.pop(context); // Pop this selection screen
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
      ),
    );
  }
}