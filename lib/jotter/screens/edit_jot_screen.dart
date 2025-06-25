// screens/edit_jot_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import 'package:uuid/uuid.dart'; // For generating ID for new jots
import 'package:collection/collection.dart'; // Make sure to import

class EditJotScreen extends StatefulWidget {
  final String? jotId; // If null, creating a new jot
  final String? preselectedContactId; // For creating a new jot for a specific contact

  const EditJotScreen({Key? key, this.jotId, this.preselectedContactId}) : super(key: key);

  @override
  _EditJotScreenState createState() => _EditJotScreenState();
}

class _EditJotScreenState extends State<EditJotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final Uuid _uuid = Uuid();

  JotItem? _existingJot;
  bool _isNewJot = true;
  String? _targetContactId; // The contact this jot is for

  @override
  void initState() {
    super.initState();
    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);

    if (widget.jotId != null) {
      _isNewJot = false;
      _existingJot = jotterProvider.getJotById(widget.jotId!);
      if (_existingJot != null) {
        _titleController.text = _existingJot!.title;
        _contentController.text = _existingJot!.textContent ?? "";
        _targetContactId = _existingJot!.contactUserId;
      } else {
        // Jot not found, handle error or pop (e.g., if deleted)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jot not found.")),
          );
        });
      }
    } else {
      _isNewJot = true;
      // If preselectedContactId is provided (from contact selection screen), use it.
      // Otherwise, default to the currently selected contact in the provider,
      // or finally, the current user if no contact is selected.
      _targetContactId = widget.preselectedContactId ??
          jotterProvider.selectedContact?.userId ??
          jotterProvider.currentUserId;
      _titleController.text = ""; // Start with an empty title for new jots
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveJot() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final jotterProvider = Provider.of<JotterProvider>(context, listen: false);

      final String jotId = _isNewJot ? _uuid.v4() : _existingJot!.id;
      final now = DateTime.now();

      final JotItem jotToSave = JotItem(
        id: jotId,
        contactUserId: _targetContactId!, // Should be set in initState
        title: _titleController.text.trim(),
        textContent: _contentController.text.trim(),
        // Media and checklist items will be handled later
        mediaAttachments: _isNewJot ? [] : _existingJot?.mediaAttachments ?? [],
        checklistItems: _isNewJot ? [] : _existingJot?.checklistItems ?? [],
        createdAt: _isNewJot ? now : _existingJot!.createdAt,
        updatedAt: now,
        createdByUserId: _isNewJot ? jotterProvider.currentUserId : _existingJot?.createdByUserId ?? jotterProvider.currentUserId,
      );

      jotterProvider.addOrUpdateJot(jotToSave).then((_) {
        Navigator.pop(context); // Go back after saving
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isNewJot ? "Jot created!" : "Jot updated!")),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving jot: $error")),
        );
      });
    }
  }

  void _deleteJot() {
    if (_existingJot != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete Jot?"),
          content: const Text("Are you sure you want to delete this jot? This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Provider.of<JotterProvider>(context, listen: false)
                    .deleteJot(_existingJot!.id)
                    .then((_) {
                  Navigator.pop(context); // Go back from edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jot deleted")),
                  );
                });
              },
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // If jot wasn't found in initState (for an existing jotId), don't build the form.
    if (!_isNewJot && _existingJot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Jot could not be loaded.")),
      );
    }

    // Determine the contact name for the AppBar
    String appBarTitle = _isNewJot ? "New Jot" : "Edit Jot";
    final provider = Provider.of<JotterProvider>(context, listen: false);
    JotterContact? associatedContact;
    if (_targetContactId != null) {
      final contactsList = provider.contactsForPanel;
      if (_targetContactId == provider.currentUserId) {
        // For current user, we want to ensure "My Jots" is used if not found by specific ID for some reason
        // or if the contactsForPanel getter itself provides it.
        // The current logic for contactsForPanel in JotterProvider should already ensure
        // the first item is "My Jots" if the current user is selected or has no specific contact entry.
        associatedContact = contactsList.firstWhereOrNull((c) => c.userId == provider.currentUserId);
        // If, for some strange reason, it's still null, default to a "My Jots" instance.
        associatedContact ??= JotterContact(userId: provider.currentUserId, displayName: "My Jots");

      } else {
        associatedContact = contactsList.firstWhereOrNull((c) => c.userId == _targetContactId);
        // If associatedContact is null here, it means the contactId provided
        // doesn't exist in the panel. The AppBar title will then fall back to "New Jot" / "Edit Jot".
        // You might want to log this scenario if it's unexpected.
        if (associatedContact == null) {
          print("Warning: Jot targetContactId '$_targetContactId' not found in contactsForPanel.");
        }
      }
    }


    if (associatedContact != null) {
      appBarTitle = _isNewJot ? "New Jot for ${associatedContact.displayName}" : "Edit Jot for ${associatedContact.displayName}";
      if (associatedContact.displayName == "My Jots") {
        appBarTitle = _isNewJot ? "New Jot for Myself" : "Edit My Jot";
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (!_isNewJot)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Delete Jot",
              onPressed: _deleteJot,
            ),
          IconButton(
            icon: const Icon(Icons.save_alt_rounded),
            tooltip: "Save Jot",
            onPressed: _saveJot,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  hintText: "Enter the main topic of your jot",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  hintText: "Jot down your notes, ideas, measurements...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Good for multi-line
                ),
                maxLines: 10, // Adjust as needed
                textCapitalization: TextCapitalization.sentences,
                // No validator for content, can be empty
              ),
              const SizedBox(height: 24.0),
              // --- Placeholder for Media/Checklist Buttons ---
              const Text(
                "Attachments (Coming Soon):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.add_a_photo_outlined), onPressed: () {/* TODO */}, tooltip: "Add Image"),
                  IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {/* TODO */}, tooltip: "Add Video"),
                  IconButton(icon: const Icon(Icons.checklist_rtl_rounded), onPressed: () {/* TODO */}, tooltip: "Add Checklist"),
                  IconButton(icon: const Icon(Icons.mic_none_outlined), onPressed: () {/* TODO */}, tooltip: "Add Audio"),
                ],
              ),
              // --- Placeholder for displaying existing media/checklists ---
            ],
          ),
        ),
      ),
    );
  }
}