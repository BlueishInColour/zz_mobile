// screens/view_jot_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import 'edit_jot_screen.dart'; // For navigating to edit

class ViewJotScreen extends StatelessWidget {
  final String jotId;

  const ViewJotScreen({Key? key, required this.jotId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jotterProvider = Provider.of<JotterProvider>(context);
    final JotItem? jot = jotterProvider.getJotById(jotId);
    final theme = Theme.of(context); // Get theme for styling

    // --- Handling Jot Not Found ---
    // This logic runs if the jot is null when the widget initially builds.
    if (jot == null) {
      // Use addPostFrameCallback to ensure actions like pop occur after the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // It's good practice to check if the widget that provided the `context`
        // is still part of the tree, especially before navigation or showing dialogs.
        // For a StatelessWidget, the context is valid as long as the widget is in the tree.
        // If this screen itself is popped rapidly, subsequent calls might fail.
        // However, Navigator.canPop itself is a safe check.

        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Attempt to go back to the previous screen.
        }
        // Show a SnackBar. It will try to find the nearest Scaffold.
        // If this screen was just popped, it should appear on the screen revealed.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Jot not found or has been deleted.")),
        );
      });
      // Return a placeholder UI while the pop/SnackBar logic is queued.
      return Scaffold(
        appBar: AppBar(title: const Text("Jot Not Found")),
        body: const Center(child: Text("This jot could not be loaded.")),
      );
    }

    // --- Determine AppBar Title ---
    // Make the AppBar title more generic or contextual to the contact.
    String appBarTitle = "View Jot"; // Default generic title
    final contact = jotterProvider.getContactById(jot.contactUserId);
    if (contact != null) {
      appBarTitle = contact.displayName; // Use contact's name if available
    }

    // --- Main Scaffold UI ---
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Jot",
            onPressed: () {
              // Use pushReplacement for a cleaner navigation stack when editing.
              // When EditJotScreen pops, it will return to the screen *before* ViewJotScreen.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditJotScreen(jotId: jot.id),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Delete Jot",
            onPressed: () async {
              // Show confirmation dialog before deleting.
              final confirmDelete = await showDialog<bool>(
                context: context, // Original context is fine for showing the dialog
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Delete Jot?'),
                    content: const Text('Are you sure you want to delete this jot permanently?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false); // User canceled
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        child: const Text('Delete'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true); // User confirmed
                        },
                      ),
                    ],
                  );
                },
              );

              // If the user confirmed deletion:
              if (confirmDelete == true) {
                await jotterProvider.deleteJot(jot.id);

                // After the await, the widget might have been disposed if the user
                // navigated away very quickly or if the delete operation was very long.
                // We check if we can pop the current screen.
                // The 'context' here is the original BuildContext of this widget.
                // If this widget is no longer in the tree, using its context can be problematic,
                // but Navigator.canPop/pop are generally safe.

                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Pop ViewJotScreen
                  // Show SnackBar. It will appear on the screen that is revealed.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jot deleted")),
                  );
                } else {
                  // This case is less common if ViewJotScreen is always pushed.
                  // It means this screen might be the root or can't be popped.
                  // Still show a SnackBar for feedback.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jot deleted (screen not popped)")),
                  );
                  // Consider if any other action is needed if the screen cannot be popped.
                  // For example, navigating to a default screen or refreshing some state.
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INTEGRATED TITLE ---
            if (jot.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SelectableText( // Made title selectable too
                  jot.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  toolbarOptions: const ToolbarOptions(copy: true, selectAll: true), // Optional: customize toolbar
                ),
              ),

            // --- JOT CONTENT ---
            if (jot.textContent != null && jot.textContent!.isNotEmpty)
              SelectableText(
                jot.textContent!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 17, // Slightly larger for readability
                  height: 1.5, // Line height
                ),
              )
            else
              Padding( // Added padding for the placeholder text
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "This jot has no text content.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 24), // Space before metadata

            // --- METADATA (Example: Created/Updated Dates) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Last updated: ${MaterialLocalizations.of(context).formatMediumDate(jot.updatedAt)} at ${TimeOfDay.fromDateTime(jot.updatedAt).format(context)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            // You can add more sections here for checklists, media attachments, etc.
          ],
        ),
      ),
    );
  }
}