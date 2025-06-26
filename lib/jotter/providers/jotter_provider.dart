// providers/jotter_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import '../models/jot_models.dart';

class JotterProvider with ChangeNotifier {
  // --- Private Properties ---
  List<JotItem> _jots = [];
  List<JotterContact> _contacts = []; // This will be the raw list of external contacts
  JotterContact? _selectedContact;
  bool _isLoading = false;
  bool _isPanelExpanded = false;

  // --- Public Getters ---
  String get currentUserId => "user_me"; // Example current user ID
  String? get currentUserAvatarUrl => "https://i.pravatar.cc/150?u=user_me"; // Example, replace with actual

  bool get isLoading => _isLoading;
  bool get isPanelExpanded => _isPanelExpanded;
  JotterContact? get selectedContact => _selectedContact;

  /// Returns a list of contacts to be displayed in the panel,
  /// including a special "My Jots" entry for the current user.
  List<JotterContact> get contactsForPanel {
    // Create the "My Jots" contact object for the panel
    final selfContact = JotterContact(
      userId: currentUserId,
      displayName: "My Jots",
      avatarUrl: currentUserAvatarUrl, // Use the getter for consistency
      // No jotCount here, as it's a special entry.
      // You could calculate it if needed: _jots.where((j) => j.contactUserId == currentUserId).length
    );

    // Filter out the current user from the main contacts list (if they exist there)
    // and then insert the special 'selfContact' at the beginning.
    List<JotterContact> panelContacts = _contacts
        .where((contact) => contact.userId != currentUserId)
        .toList();
    panelContacts.insert(0, selfContact);

    return panelContacts;
  }

  /// Returns jots filtered for the currently selected contact in the panel.
  /// If no contact is selected (shouldn't happen after init), defaults to "My Jots".
  List<JotItem> get jotsForSelectedContact {
    final targetId = _selectedContact?.userId ?? currentUserId;
    return _jots
        .where((jot) => jot.contactUserId == targetId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by most recent
  }

  /// Returns all jots (primarily for internal use or if needed elsewhere).
  List<JotItem> get allJots => List.unmodifiable(_jots);


  // --- Constructor & Initializer ---
  JotterProvider() {
    _loadInitialDataAndSelectSelf();
  }

  Future<void> _loadInitialDataAndSelectSelf() async {
    _isLoading = true;
    // notifyListeners(); // Consider if you want an immediate loading state update

    // Simulate loading external contacts (excluding the current user explicitly)
    // In a real app, this would be an API call or database query.
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    _contacts = [
      JotterContact(userId: "contact_1", displayName: "Alice Wonderland", avatarUrl: "https://i.pravatar.cc/150?img=1"),
      JotterContact(userId: "contact_2", displayName: "Bob The Builder", avatarUrl: "https://i.pravatar.cc/150?img=2"),
      JotterContact(userId: "contact_3", displayName: "Charlie Brown", avatarUrl: "https://i.pravatar.cc/150?img=3"),
      // Note: currentUserId ("user_me") is NOT in this list.
      // The "My Jots" entry is dynamically added by contactsForPanel.
    ];

    // Simulate loading jots
    final Uuid uuid = Uuid();
    final now = DateTime.now();
    _jots = [
      JotItem(id: uuid.v4(), contactUserId: currentUserId, title: "My Grocery List", textContent: "Milk, Eggs, Bread, Cheese.", createdAt: now.subtract(const Duration(days: 1)), updatedAt: now.subtract(const Duration(days: 1)), createdByUserId: currentUserId),
      JotItem(id: uuid.v4(), contactUserId: currentUserId, title: "My Meeting Notes", textContent: "Project X discussion.", createdAt: now.subtract(const Duration(hours: 5)), updatedAt: now.subtract(const Duration(hours: 4)), createdByUserId: currentUserId),
      JotItem(id: uuid.v4(), contactUserId: "contact_1", title: "Ideas for Alice", textContent: "Gift ideas, project thoughts.", createdAt: now.subtract(const Duration(days: 2)), updatedAt: now.subtract(const Duration(days: 2)), createdByUserId: currentUserId),
      JotItem(id: uuid.v4(), contactUserId: currentUserId, title: "My Workout Plan", textContent: "Gym session details.", createdAt: now.subtract(const Duration(hours: 10)), updatedAt: now.subtract(const Duration(hours: 10)), createdByUserId: currentUserId),
      JotItem(id: uuid.v4(), contactUserId: "contact_2", title: "Bob's Project Specs", textContent: "Requirements for the new shed.", createdAt: now.subtract(const Duration(days: 3)), updatedAt: now.subtract(const Duration(days: 2, hours: 5)), createdByUserId: currentUserId),
    ];

    // Select "My Jots" by default after data is loaded.
    // We find it in the generated `contactsForPanel` list.
    _selectedContact = contactsForPanel.firstWhereOrNull((c) => c.userId == currentUserId);

    // Fallback if "My Jots" somehow wasn't found (shouldn't happen with current logic)
    if (_selectedContact == null && contactsForPanel.isNotEmpty) {
      _selectedContact = contactsForPanel.first;
    } else if (_selectedContact == null) {
      // Absolute fallback: create a temporary self contact if panel is empty (edge case)
      _selectedContact = JotterContact(userId: currentUserId, displayName: "My Jots", avatarUrl: currentUserAvatarUrl);
    }

    _isLoading = false;
    notifyListeners(); // Notify that initial data is ready and selected contact is set
  }

  // --- UI Interaction Methods ---
  void togglePanel() {
    _isPanelExpanded = !_isPanelExpanded;
    notifyListeners();
  }

  void selectContact(JotterContact contact) {
    if (_selectedContact?.userId != contact.userId) {
      _selectedContact = contact;
      // Potentially close panel when a contact is selected, depending on UX preference
      // if (_isPanelExpanded) {
      //   _isPanelExpanded = false;
      // }
      notifyListeners();
    }
  }

  // --- Data Manipulation Methods ---
  Future<void> addOrUpdateJot(JotItem jot, {bool silent = false}) async {
    final index = _jots.indexWhere((j) => j.id == jot.id);
    if (index != -1) {
      _jots[index] = jot; // Update existing
    } else {
      _jots.add(jot); // Add new
    }

    if (!silent) {
      // If the jot's contact is different from the currently selected one,
      // update the selected contact to show the newly added/updated jot.
      if (_selectedContact?.userId != jot.contactUserId) {
        final contactToSelect = getContactById(jot.contactUserId);
        if (contactToSelect != null) {
          _selectedContact = contactToSelect;
        } else {
          // This case means a jot was added for a contact not in the panel.
          // This shouldn't happen if jots are always for existing contacts or "My Jots".
          // If it can, you might need to add a temporary contact or handle it.
          print("Warning: Jot added/updated for contact '${jot.contactUserId}', which is not in the panel. Selecting 'My Jots'.");
          _selectedContact = getContactById(currentUserId); // Fallback to "My Jots"
        }
      }
      notifyListeners();
    }
  }

  Future<void> deleteJot(String jotId) async {
    _jots.removeWhere((j) => j.id == jotId);
    notifyListeners();
  }

  // --- Data Accessor Methods ---

  /// Retrieves a specific jot by its ID.
  JotItem? getJotById(String jotId) {
    return _jots.firstWhereOrNull((j) => j.id == jotId);
  }

  /// Retrieves contact details by user ID.
  /// This will check the main `_contacts` list and also handle the `currentUserId` case.
  JotterContact? getContactById(String userId) {
    if (userId == currentUserId) {
      return JotterContact(
        userId: currentUserId,
        displayName: "My Jots", // Or "Myself" / user's actual name if available
        avatarUrl: currentUserAvatarUrl,
      );
    }
    return _contacts.firstWhereOrNull((contact) => contact.userId == userId);
  }

  /// Placeholder for a method to reload jots, e.g., on pull-to-refresh.
  /// You might want to make this more specific, like `reloadJotsForSelectedContact()`.
  Future<void> refreshJots() async {
    _isLoading = true;
    notifyListeners();
    // Simulate fetching new data
    await Future.delayed(const Duration(seconds: 1));
    // Here you would re-fetch _jots and potentially _contacts
    // For now, just end loading state
    _isLoading = false;
    notifyListeners();
  }
}