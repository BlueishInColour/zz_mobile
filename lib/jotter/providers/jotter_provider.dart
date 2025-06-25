// providers/jotter_provider.dart
import 'package:flutter/material.dart';
import '../models/jot_models.dart'; // Your data models
import 'package:uuid/uuid.dart';

const String _currentUserId = "currentUserDemoId";

class JotterProvider with ChangeNotifier {
  final Uuid _uuid = Uuid();

  List<JotterContact> _contacts = [];
  List<JotItem> _allJots = [];

  JotterContact? _selectedContact;
  bool _isLoading = false;
  bool _isPanelExpanded = true;

  List<JotterContact> get contactsForPanel {
    List<JotterContact> sortedContacts = List.from(_contacts);
    JotterContact? currentUserContact;
    int currentUserIndex = sortedContacts.indexWhere((c) => c.userId == _currentUserId);

    if (currentUserIndex != -1) {
      currentUserContact = sortedContacts.removeAt(currentUserIndex);
    } else {
      currentUserContact = JotterContact(userId: _currentUserId, displayName: "My Jots");
    }

    sortedContacts.sort((a, b) {
      if (a.lastJotActivity == null && b.lastJotActivity == null) return 0;
      if (a.lastJotActivity == null) return 1;
      if (b.lastJotActivity == null) return -1;
      return b.lastJotActivity!.compareTo(a.lastJotActivity!);
    });
    return [currentUserContact, ...sortedContacts];
  }

  JotterContact? get selectedContact => _selectedContact;

  List<JotItem> get jotsForSelectedContact {
    List<JotItem> filteredJots;

    if (_selectedContact == null) {
      if (contactsForPanel.isNotEmpty && contactsForPanel.first.userId == _currentUserId) {
        filteredJots = _allJots
            .where((jot) => jot.contactUserId == _currentUserId)
            .toList(); // Convert to List first
      } else {
        return [];
      }
    } else {
      filteredJots = _allJots
          .where((jot) => jot.contactUserId == _selectedContact!.userId)
          .toList(); // Convert to List first
    }
    // Now call the extension method on the List
    return filteredJots.orderByUpdatedAtDesc();
  }

  bool get isLoading => _isLoading;
  bool get isPanelExpanded => _isPanelExpanded;
  String get currentUserId => _currentUserId;

  JotterProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    _contacts = [
      JotterContact(userId: "contact_jane", displayName: "Jane Doe", avatarUrl: "https://i.pravatar.cc/150?img=5", lastJotActivity: DateTime.now().subtract(const Duration(hours: 2))),
      JotterContact(userId: "contact_john", displayName: "John Smith", avatarUrl: "https://i.pravatar.cc/150?img=12", lastJotActivity: DateTime.now().subtract(const Duration(days: 1))),
    ];

    _allJots = [
      JotItem(id: _uuid.v4(), contactUserId: _currentUserId, title: "My Fashion Sketch Idea", textContent: "A flowing gown with intricate lace details...", createdAt: DateTime.now().subtract(const Duration(minutes: 30)), updatedAt: DateTime.now().subtract(const Duration(minutes: 30))),
      JotItem(id: _uuid.v4(), contactUserId: _currentUserId, title: "Fabric Swatches to Check", textContent: "Silk, Velvet, Cotton blend for the summer collection.", createdAt: DateTime.now().subtract(const Duration(hours: 5)), updatedAt: DateTime.now().subtract(const Duration(hours: 5))),
      JotItem(id: _uuid.v4(), contactUserId: "contact_jane", title: "Meeting Notes with Jane", textContent: "Discussed mood board and color palette. She liked the teal inspiration.", createdAt: DateTime.now().subtract(const Duration(hours: 1)), updatedAt: DateTime.now().subtract(const Duration(hours: 1))),
      JotItem(id: _uuid.v4(), contactUserId: "contact_john", title: "Measurements for John's Suit", textContent: "Chest: 40, Waist: 32, Inseam: 30. Needs adjustment on shoulder.", createdAt: DateTime.now().subtract(const Duration(days: 2)), updatedAt: DateTime.now().subtract(const Duration(days: 2))),
    ];

    if (contactsForPanel.isNotEmpty) {
      _selectedContact = contactsForPanel.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectContact(JotterContact contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  void togglePanel() {
    _isPanelExpanded = !_isPanelExpanded;
    notifyListeners();
  }

  Future<void> addOrUpdateJot(JotItem jot) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _allJots.indexWhere((j) => j.id == jot.id);
    final now = DateTime.now();
    jot.updatedAt = now; // Ensure updatedAt is current

    if (index != -1) {
      _allJots[index] = jot;
    } else {
      jot.createdAt = now; // Set createdAt for new jots
      _allJots.add(jot);
    }

    final contactIndex = _contacts.indexWhere((c) => c.userId == jot.contactUserId);
    if (contactIndex != -1) {
      _contacts[contactIndex].lastJotActivity = now;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteJot(String jotId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _allJots.removeWhere((j) => j.id == jotId);
    _isLoading = false;
    notifyListeners();
  }

  JotItem? getJotById(String jotId) {
    try {
      return _allJots.firstWhere((jot) => jot.id == jotId);
    } catch (e) {
      return null;
    }
  }
}

// Helper extension for sorting (can be in a separate utils file)
// This extension works on a List<T> and sorts it in place, then returns it.
extension ListUpdateSort<T> on List<T> {
  List<T> orderByUpdatedAtDesc() {
    // Sort logic needs to ensure it's comparing JotItems
    if (T == JotItem) {
      this.sort((a, b) {
        // Cast to JotItem to access updatedAt
        final JotItem jotA = a as JotItem;
        final JotItem jotB = b as JotItem;
        return jotB.updatedAt.compareTo(jotA.updatedAt);
      });
    } else {
      // Optionally handle or throw error if called on a list of non-JotItems
      // For now, it will only work if T is JotItem
      print("Warning: orderByUpdatedAtDesc called on a list that is not of JotItem type.");
    }
    return this;
  }
}