// providers/accounting_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import '../models/account_models.dart';
// Import your database/storage service here if you have one

class AccountingProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<FinancialTransaction> _transactions = [];
  bool _isLoading = false;
  String _currentUserId = ""; // Assume this is set, perhaps from an AuthProvider

  // --- Getters ---
  List<FinancialTransaction> get allTransactions => List.unmodifiable(_transactions);
  List<FinancialTransaction> get incomeTransactions =>
      _transactions.where((t) => t.type == TransactionType.income).toList();
  List<FinancialTransaction> get expenseTransactions =>
      _transactions.where((t) => t.type == TransactionType.expense).toList();
  bool get isLoading => _isLoading;

  // --- Current User ---
  void setCurrentUserId(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      loadTransactions(); // Reload transactions for the new user
    }
  }


  AccountingProvider({String initialUserId = ""}) {
    _currentUserId = initialUserId;
    if (_currentUserId.isNotEmpty) {
      loadTransactions();
    }
  }

  // --- CRUD Operations ---

  Future<void> loadTransactions() async {
    if (_currentUserId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    // TODO: Replace with actual data loading from your database/storage
    // For now, simulate a delay and use dummy data if empty
    await Future.delayed(const Duration(milliseconds: 800));
    // Example: _transactions = await _databaseService.getTransactions(_currentUserId);

    if (_transactions.isEmpty && _currentUserId.isNotEmpty) { // Only add dummy if list is empty
      _addDummyTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDummyTransactions() {
    final now = DateTime.now();
    _transactions.addAll([
      FinancialTransaction(id: _uuid.v4(), type: TransactionType.income, title: "Salary - Jan", amount: 2500.00, date: now.subtract(const Duration(days: 30)), category: "Salary", userId: _currentUserId),
      FinancialTransaction(id: _uuid.v4(), type: TransactionType.income, title: "Freelance Project X", amount: 850.00, date: now.subtract(const Duration(days: 15)), category: "Freelance", userId: _currentUserId),
      FinancialTransaction(id: _uuid.v4(), type: TransactionType.expense, title: "Rent", amount: 1200.00, date: now.subtract(const Duration(days: 28)), category: "Housing", userId: _currentUserId),
      FinancialTransaction(id: _uuid.v4(), type: TransactionType.expense, title: "Groceries", amount: 150.75, date: now.subtract(const Duration(days: 10)), category: "Food", userId: _currentUserId),
      FinancialTransaction(id: _uuid.v4(), type: TransactionType.expense, title: "Internet Bill", amount: 60.00, date: now.subtract(const Duration(days: 5)), category: "Utilities", userId: _currentUserId),
    ]);
  }


  Future<void> addTransaction(FinancialTransaction transaction) async {
    // Basic validation
    if (transaction.userId != _currentUserId) {
      print("Error: Transaction user ID does not match current user.");
      return;
    }
    // TODO: Save to database/storage
    // await _databaseService.insertTransaction(transaction);

    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date)); // Keep sorted by date
    notifyListeners();
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    // TODO: Update in database/storage
    // await _databaseService.updateTransaction(transaction);

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    // TODO: Delete from database/storage
    // await _databaseService.deleteTransaction(transactionId);

    _transactions.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }

  // --- Summary Calculations ---
  AccountSummary getAccountSummary({DateTime? startDate, DateTime? endDate}) {
    List<FinancialTransaction> filteredTransactions = _transactions;

    // TODO: Add filtering by date range if startDate and endDate are provided

    double totalIncome = filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);

    double totalExpenses = filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);

    return AccountSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netBalance: totalIncome - totalExpenses,
    );
  }

  // Common categories (could be user-defined later)
  List<String> get incomeCategories => ["Salary", "Freelance", "Investment", "Bonus", "Other Income"];
  List<String> get expenseCategories => ["Housing", "Food", "Transportation", "Utilities", "Healthcare", "Entertainment", "Education", "Other Expense"];
}