// widgets/jot_list_display.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import '../screens/edit_jot_screen.dart';

// Import a masonry grid package if you have one, e.g.:
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class JotListDisplay extends StatelessWidget {
  const JotListDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<JotterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.jotsForSelectedContact.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final jots = provider.jotsForSelectedContact;

        if (jots.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                provider.selectedContact?.displayName == "My Jots"
                    ? "You haven't added any jots yet.\nTap the '+' button to create one!"
                    : "No jots for ${provider.selectedContact?.displayName ?? 'this contact'}.\nTap the '+' button to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
          );
        }

        // --- Placeholder: Simple ListView ---
        // Replace this with your Masonry Grid implementation later
        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: jots.length,
          itemBuilder: (context, index) {
            final jot = jots[index];
            return _JotPreviewCard(jot: jot); // We'll create this simple card next
          },
        );

        /*
        // --- TODO: Replace with Masonry Grid ---
        return MasonryGridView.count(
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: 2, // Adjust as needed, make it responsive
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          itemCount: jots.length,
          itemBuilder: (context, index) {
            final jot = jots[index];
            return _JotPreviewCard(jot: jot);
          },
        );
        */
      },
    );
  }
}

// Simple Preview Card for a Jot Item (will be used in Masonry Grid)
class _JotPreviewCard extends StatelessWidget {
  final JotItem jot;

  const _JotPreviewCard({Key? key, required this.jot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        onTap: () {
          // Navigate to EditJotScreen to view/edit this jot
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditJotScreen(jotId: jot.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important for varying card heights in Masonry
            children: [
              Text(
                jot.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                jot.contentPreview, // Using the getter from JotItem model
                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.3),
                maxLines: 3, // Adjust as needed for preview length
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                // Using intl package for date formatting would be nice here
                "Last updated: ${TimeOfDay.fromDateTime(jot.updatedAt).format(context)} - ${MaterialLocalizations.of(context).formatShortDate(jot.updatedAt)}",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}