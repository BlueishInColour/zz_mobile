// screens/jotter_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../widgets/jotter_contacts_panel.dart';
import '../widgets/jot_list_display.dart'; // We'll create this next
import 'edit_jot_screen.dart'; // We'll create this later

class JotterTabScreen extends StatelessWidget {
  const JotterTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure JotterProvider is available.
    // You should have already added it to your MultiProvider in main.dart or a similar setup.
    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<JotterProvider>(
          builder: (context, provider, child) {
            return Text(provider.selectedContact?.displayName ?? 'Jotter');
          },
        ),
        // Potentially add actions like search later
      ),
      body: Row(
        children: [
          // Contacts Panel (conditionally shown based on provider state)
          Consumer<JotterProvider>(
            builder: (context, provider, child) {
              if (provider.isPanelExpanded) {
                return const JotterContactsPanel();
              }
              return const SizedBox.shrink(); // Collapsed
            },
          ),

          // Main content area for displaying jots
          const Expanded(
            child: JotListDisplay(), // This will hold the masonry grid
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the EditJotScreen to create a new jot.
          // The selected contact in the provider will be the default contact for the new jot.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditJotScreen(
                // Passing null for jotId means creating a new jot
                // The EditJotScreen will use provider.selectedContact or provider.currentUserId
              ),
            ),
          );
        },
        tooltip: 'New Jot',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}