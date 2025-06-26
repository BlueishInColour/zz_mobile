// screens/jotter_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import '../widgets/jotter_contacts_panel.dart';
import 'view_jot_screen.dart'; // Import ViewJotScreen
// import 'edit_jot_screen.dart'; // EditJotScreen is now accessed from ViewJotScreen
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // <<< ADD THIS IMPORT

class JotterTabScreen extends StatefulWidget {
  const JotterTabScreen({Key? key}) : super(key: key);

  @override
  _JotterTabScreenState createState() => _JotterTabScreenState();
}

class _JotterTabScreenState extends State<JotterTabScreen> {
  // Uuid instance can be here if _ensureDummyDataIfNeeded needs it frequently,
  // or local to the method if only used there.
  // final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // The JotterProvider's constructor initiates loading.
    // We'll use addPostFrameCallback to check if dummy data needs to be added
    // after the initial build and potential data load from the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the context is still valid if the widget was disposed quickly
      if (mounted) {
        final jotterProvider = Provider.of<JotterProvider>(context, listen: false);
        // Check if the provider has finished its initial loading phase
        if (!jotterProvider.isLoading) {
          _ensureDummyDataIfNeeded(jotterProvider);
        }
      }
    });
  }

  // --- Helper for DUMMY DATA (Conditional) ---
  void _ensureDummyDataIfNeeded(JotterProvider provider) {
    // Determine if dummy data should be added.
    // This condition checks if there are no jots for the currently selected contact
    // OR if no contact is selected yet, it checks if there are no jots for "My Jots".
    bool shouldAddDummyData = false;
    if (provider.selectedContact != null) {
      // Check jots for the explicitly selected contact
      if (provider.jotsForSelectedContact.isEmpty) {
        shouldAddDummyData = true;
      }
    } else {
      // If no contact is selected yet (e.g., during very initial app load before provider fully settles)
      // check jots for the current user ("My Jots")
      final myJots = provider.allJots.where((j) => j.contactUserId == provider.currentUserId);
      if (myJots.isEmpty) {
        shouldAddDummyData = true;
      }
    }

    // Only add dummy data if necessary and currentUserId is available
    if (shouldAddDummyData && provider.currentUserId.isNotEmpty) {
      print("INFO: No jots found for initial view. Adding dummy data for demonstration.");
      final now = DateTime.now();
      final Uuid uuid = Uuid(); // Local Uuid instance is fine here

      // Determine the target contact ID for dummy jots
      // Prefers selectedContact, falls back to currentUserId
      final String targetContactIdForDummyJots = provider.selectedContact?.userId ?? provider.currentUserId;

      final dummyJots = [
        JotItem(id: uuid.v4(), contactUserId: targetContactIdForDummyJots, title: "Welcome Jot!", textContent: "This is a sample jot. Tap on me to view, then tap the edit icon!", createdAt: now.subtract(const Duration(minutes: 5)), updatedAt: now.subtract(const Duration(minutes: 5)), createdByUserId: provider.currentUserId),
        JotItem(id: uuid.v4(), contactUserId: targetContactIdForDummyJots, title: "Grocery List", textContent: "Milk, Eggs, Bread, Cheese, Apples, Bananas, Chicken Breast, Spinach", createdAt: now.subtract(const Duration(days: 1)), updatedAt: now.subtract(const Duration(days: 1)), createdByUserId: provider.currentUserId),
        JotItem(id: uuid.v4(), contactUserId: targetContactIdForDummyJots, title: "Meeting Notes - Project Phoenix", textContent: "Key takeaways:\n- Timeline adjustment approved.\n- Need to finalize budget by EOD Friday.\n- Sarah to follow up on vendor contracts.", createdAt: now.subtract(const Duration(hours: 5)), updatedAt: now.subtract(const Duration(hours: 4)), createdByUserId: provider.currentUserId),
        // Add more varied dummy jots if you like
      ];

      for (var jot in dummyJots) {
        // Add silently to avoid potential selection changes if provider.addOrUpdateJot handles that
        provider.addOrUpdateJot(jot, silent: true);
      }

      // After adding dummy data, the Consumer widget listening to the provider
      // should automatically pick up the changes and rebuild the list.
      // Explicitly calling selectContact might be needed if addOrUpdateJot(silent:true)
      // doesn't trigger a broad enough notification for the selectedContact's list to update.
      // However, usually, if _jots list changes and jotsForSelectedContact depends on _jots,
      // it should rebuild. For safety, or if issues arise:
      // if (provider.selectedContact != null) {
      //   provider.selectContact(provider.selectedContact!); // Re-assert selection to ensure UI update
      // } else {
      //   final myJotsContact = provider.contactsForPanel.firstWhere((c) => c.userId == provider.currentUserId, orElse: () => provider.contactsForPanel.first);
      //   provider.selectContact(myJotsContact);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    // No need to get jotterProvider here if not used directly in this build method
    // before the Consumer.

    return Scaffold(
      appBar: AppBar(
        // Title could be dynamic based on selected contact later if desired
        title: Consumer<JotterProvider>(
            builder: (context, provider, child) {
              return Text(provider.selectedContact?.displayName ?? 'Jotter');
            }
        ),
        centerTitle: true, // Example: center the title
        elevation: 0.5,
        // The JotterContactsPanel has its own toggle button.
        // If you want a global toggle in AppBar, you'd add it here.
      ),
      body: Row(
        children: [
          const JotterContactsPanel(), // Panel width is managed internally or via props
          Expanded(
            child: Consumer<JotterProvider>(
              builder: (context, provider, child) {
                // Get jots AFTER checking isLoading, as jotsForSelectedContact might be empty
                // during the initial load phase, leading to a premature "No jots" message.
                if (provider.isLoading && provider.jotsForSelectedContact.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jotsToDisplay = provider.jotsForSelectedContact;

                if (jotsToDisplay.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_add_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "No jots yet for ${provider.selectedContact?.displayName ?? "this view"}.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap the '+' button in the contacts panel to create your first jot for ${provider.selectedContact?.displayName ?? "this contact"}!",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Using MasonryGridView for the two-column layout
                return RefreshIndicator(
                  onRefresh: () => provider.refreshJots(), // Hook up pull-to-refresh
                  child: MasonryGridView.count(
                    padding: const EdgeInsets.all(12.0),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    itemCount: jotsToDisplay.length,
                    itemBuilder: (context, index) {
                      final jot = jotsToDisplay[index];
                      return JotPreviewCard(jot: jot);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // FloatingActionButton is removed as "Add Jot" is now in the JotterContactsPanel.
    );
  }
}
//
// ... (JotterTabScreen and _JotterTabScreenState remain the same) ...


class JotPreviewCard extends StatelessWidget {
  final JotItem jot;

  const JotPreviewCard({Key? key, required this.jot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Prepare a very short date string
    // Using intl package for better and more flexible formatting
    final String shortDateString = DateFormat.Md().format(jot.updatedAt); // e.g., "7/15" or "Jul 15" depending on locale

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewJotScreen(jotId: jot.id)),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.95),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (jot.title.isNotEmpty)
              Text(
                jot.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (jot.title.isNotEmpty && (jot.textContent?.isNotEmpty ?? false))
              const SizedBox(height: 8.0),
            if (jot.textContent?.isNotEmpty ?? false)
              Text(
                jot.textContent!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                  height: 1.4,
                ),
                maxLines: 5, // Adjust as needed
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10.0), // Space before the date row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Option 1: Icon + short date (Recommended if "Updated" prefix is important)
                Icon(
                  Icons.history_toggle_off_outlined, // Or Icons.update, Icons.schedule
                  size: 13, // Slightly smaller icon
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Flexible( // Ensures the Text widget can shrink and use ellipsis if needed
                  child: Text(
                    shortDateString, // Use the pre-formatted short date
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis, // Important for preventing overflow
                    textAlign: TextAlign.right, // Align text to the right if it wraps (less likely here)
                  ),
                ),

                // Option 2: Just text, very short (if icon is not desired)
                // Flexible(
                //   child: Text(
                //     "Upd: $shortDateString",
                //     style: theme.textTheme.bodySmall?.copyWith(
                //       color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                //       fontSize: 11,
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //     textAlign: TextAlign.right,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}