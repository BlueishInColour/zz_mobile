// screens/edit_jot_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jotter_provider.dart';
import '../models/jot_models.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'view_jot_screen.dart'; // Import the ViewJotScreen

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
  String? _targetContactId; // The contact this jot belongs to/will belong to
  JotterContact? _associatedContact; // The contact object for avatar/name

  bool _isLoading = true; // To handle async loading in initState

  @override
  void initState() {
    super.initState();
    _loadJotData();
  }

  Future<void> _loadJotData() async {
    setState(() => _isLoading = true);
    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);

    if (widget.jotId != null) {
      _isNewJot = false;
      _existingJot = jotterProvider.getJotById(widget.jotId!);
      if (_existingJot != null) {
        _titleController.text = _existingJot!.title;
        _contentController.text = _existingJot!.textContent ?? "";
        _targetContactId = _existingJot!.contactUserId;
      } else {
        // Jot not found
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jot not found.")),
          );
        }
        return; // Stop further processing
      }
    } else {
      _isNewJot = true;
      // Determine the target contact for the new jot
      if (widget.preselectedContactId != null) {
        _targetContactId = widget.preselectedContactId;
      } else if (jotterProvider.selectedContact != null) {
        _targetContactId = jotterProvider.selectedContact!.userId;
      } else {
        _targetContactId = jotterProvider.currentUserId; // Default to "My Jots"
      }
      // Title controller starts empty for new jots
    }

    // Fetch the associated contact for AppBar display
    if (_targetContactId != null) {
      _associatedContact = jotterProvider.getContactById(_targetContactId!);
      // If creating a new jot for self and getContactById doesn't explicitly return a "My Jots" contact
      if (_associatedContact == null && _targetContactId == jotterProvider.currentUserId) {
        _associatedContact = JotterContact(
          userId: jotterProvider.currentUserId,
          displayName: "My Jots", // Or your preferred term like "Myself"
          avatarUrl: jotterProvider.currentUserAvatarUrl, // Assuming you have this
        );
      }
    }

    if (!mounted) return;

    // If, after all checks, we don't have an associated contact for a jot, it's an issue.
    if (_associatedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot load jot: Contact information is missing.")),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveJot() {
    if (!_formKey.currentState!.validate()) {
      // Optionally show a message if validation fails (e.g., if you add validators)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Please fill in all required fields.")),
      // );
      return;
    }

    if (_targetContactId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Cannot determine target contact for this jot.")),
      );
      return;
    }

    final jotterProvider = Provider.of<JotterProvider>(context, listen: false);
    final String jotIdToSave = _isNewJot ? _uuid.v4() : _existingJot!.id;
    final now = DateTime.now();

    final JotItem jotToSave = JotItem(
      id: jotIdToSave,
      contactUserId: _targetContactId!,
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : "Untitled Jot",
      textContent: _contentController.text.trim(),
      mediaAttachments: _isNewJot ? [] : _existingJot?.mediaAttachments ?? [],
      checklistItems: _isNewJot ? [] : _existingJot?.checklistItems ?? [],
      createdAt: _isNewJot ? now : _existingJot!.createdAt,
      updatedAt: now,
      createdByUserId: _isNewJot ? jotterProvider.currentUserId : (_existingJot?.createdByUserId ?? jotterProvider.currentUserId),
    );

    jotterProvider.addOrUpdateJot(jotToSave).then((_) {
      if (mounted) {
        // Instead of just popping, navigate to the ViewJotScreen
        // Pop current EditJotScreen
        Navigator.pop(context);
        // Then push ViewJotScreen. If coming from ViewJotScreen (edit), this replaces it.
        // If coming from New Jot, it pushes ViewJotScreen on top of the list screen.
        Navigator.pushReplacement( // Use pushReplacement if you always want ViewScreen to replace EditScreen in stack
          context,
          MaterialPageRoute(
            builder: (context) => ViewJotScreen(jotId: jotIdToSave),
          ),
        );
        // Optional: show a confirmation SnackBar on the ViewJotScreen after redirect,
        // or pass a parameter to ViewJotScreen to show it.
        // For simplicity, we can show it briefly before navigating if needed,
        // but it's often better on the destination screen.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(_isNewJot ? "Jot created!" : "Jot updated!")),
        // );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving jot: $error")),
        );
      }
    });
  }

  // Delete button is removed from Edit screen, it's better on ViewJotScreen
  // void _deleteJot() { ... }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isNewJot ? "New Jot" : "Edit Jot")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // This check is important after _isLoading is false
    if (_associatedContact == null || (!_isNewJot && _existingJot == null)) {
      // This case should ideally be caught by _loadJotData and lead to a pop
      return Scaffold(
          appBar: AppBar(title: Text(_isNewJot ? "New Jot" : "Error")),
          body: const Center(child: Text("Could not load jot data.")));
    }


    String displayName = _associatedContact!.displayName;
    // Customize "My Jots" display name if needed
    if (_associatedContact!.userId == Provider.of<JotterProvider>(context, listen: false).currentUserId &&
        (_associatedContact!.displayName == "My Jots" || _associatedContact!.displayName == "Myself")) {
      displayName = "Myself"; // Or your preferred term like "My Jots"
    }

    String appBarDynamicTitle = _isNewJot
        ? "New Jot for $displayName"
        : (_titleController.text.trim().isNotEmpty ? _titleController.text.trim() : "Untitled Jot");


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), // More appropriate for an edit/create modal/screen
          tooltip: "Cancel",
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: (_associatedContact?.avatarUrl != null && _associatedContact!.avatarUrl!.isNotEmpty)
                  ? NetworkImage(_associatedContact!.avatarUrl!)
                  : null,
              child: (_associatedContact?.avatarUrl == null || _associatedContact!.avatarUrl!.isEmpty)
                  ? Text(
                _associatedContact!.displayName.isNotEmpty ? _associatedContact!.displayName[0].toUpperCase() : "?",
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSecondaryContainer),
              )
                  : null,
              backgroundColor: theme.colorScheme.secondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appBarDynamicTitle,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add some padding
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text("Save"),
              onPressed: _saveJot,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Title...",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: theme.hintColor.withOpacity(0.6),
                        ),
                        counterText: "",
                      ),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: theme.textTheme.titleLarge?.color),
                      // validator: (value) { // Validation is optional here as we default title on save
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Title cannot be empty'; // Or handle silently
                      //   }
                      //   return null;
                      // },
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 80,
                      onChanged: (value) {
                        // To update AppBar title dynamically as user types (optional)
                        if (!_isNewJot) setState(() {});
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Start writing...",
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: theme.hintColor.withOpacity(0.6),
                        ),
                      ),
                      style: TextStyle(fontSize: 18, height: 1.5, color: theme.textTheme.bodyLarge?.color),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Action Bar (remains the same)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
                color: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: Border(
                    top: BorderSide(
                      color: theme.dividerColor.withOpacity(0.5),
                      width: 0.5,
                    ))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildActionButton(context, Icons.add_a_photo_outlined, "Image", () {/* TODO */}),
                _buildActionButton(context, Icons.videocam_outlined, "Video", () {/* TODO */}),
                _buildActionButton(context, Icons.checklist_rtl_rounded, "Checklist", () {/* TODO */}),
                _buildActionButton(context, Icons.mic_none_outlined, "Audio", () {/* TODO */}),
                _buildActionButton(context, Icons.palette_outlined, "Style", () {/* TODO */}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 26,
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      splashRadius: 24,
    );
  }
}