import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; // Assuming this is your contacts plugin

import '../providers/chat_provider.dart';
import '../widgets/custom_contacts_panel.dart'; // Your existing panel

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isLoadingContacts = true;
  String _permissionMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    // ... (Your existing _fetchContacts logic from home_screen.dart [1]) ...
    // Make sure to handle permissions and errors
    setState(() { _isLoadingContacts = true; _permissionMessage = ""; });
    bool isGranted = await FlutterContacts.requestPermission(readonly: true);
    if (isGranted) {
      try {
        final List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true,
        );
        setState(() { _contacts = contacts; _isLoadingContacts = false; });
      } catch (e) {
        setState(() { _permissionMessage = "Error fetching contacts."; _isLoadingContacts = false; });
      }
    } else {
      setState(() { _permissionMessage = "Contacts permission denied."; _isLoadingContacts = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _isLoadingContacts
          ? const Center(child: CircularProgressIndicator())
          : _permissionMessage.isNotEmpty
          ? Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_permissionMessage, textAlign: TextAlign.center),
      ))
          : CustomContactsPanel(
        contacts: _contacts,
        // Add an "AI Chat" item at the top before passing to the panel,
        // OR modify CustomContactsPanel to conditionally show it.
        // For simplicity, let's wrap CustomContactsPanel.
        onAiChatTap: () {
          chatProvider.switchToAiChat();
          Navigator.pop(context); // Go back to MainChatHostScreen, which will show AI chat
        },
        onContactTap: (contact) {
          String contactId = contact.id;
          if (contactId.isEmpty) {
            contactId = contact.phones.isNotEmpty ? contact.phones.first.number : "unknown_contact_${contact.hashCode}";
          }
          chatProvider.switchToP2pChat(contactId, contact.displayName,"");
          Navigator.pop(context); // Go back to MainChatHostScreen, which will show P2P
        },
      ),
    );
  }
}