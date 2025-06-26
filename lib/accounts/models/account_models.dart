// models/account_models.dart
import 'package:flutter/foundation.dart'; // For @required if using older Flutter versions

enum TransactionType { income, expense }

class FinancialTransaction {
  final String id;
  final TransactionType type; // To distinguish between income and expense
  final String title;         // e.g., "Client Payment", "Office Supplies"
  final String? description;   // Optional further details
  final double amount;
  final DateTime date;
  final String? category;      // e.g., "Salary", "Freelance", "Utilities", "Travel"
  final String userId;        // To associate with the current user

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    this.category,
    required this.userId,
  });

// Optional: Add copyWith, toJson, fromJson methods if you're saving to a DB/backend
// For example, if using drift, these would be part of your table definition.
}

// You might also want a model for summarizing data, e.g.,
class AccountSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  // Potentially breakdowns by category, date range, etc.

  AccountSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });
}