// screens/add_edit_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/account_models.dart';
import '../providers/accounting_provider.dart';
// Assuming you have an AuthProvider or similar for currentUserId
// import '../providers/auth_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final FinancialTransaction? transaction; // Null if adding, populated if editing

  const AddEditTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  _AddEditTransactionScreenState createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TransactionType _selectedType;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    _selectedType = widget.transaction?.type ?? TransactionType.expense; // Default to expense
    _titleController = TextEditingController(text: widget.transaction?.title);
    _amountController = TextEditingController(
        text: widget.transaction?.amount.toStringAsFixed(2) ?? '');
    _descriptionController = TextEditingController(text: widget.transaction?.description);
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedCategory = widget.transaction?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Not strictly needed if using controllers directly

      final accountingProvider = Provider.of<AccountingProvider>(context, listen: false);
      // IMPORTANT: Get currentUserId. This might come from an AuthProvider.
      // For this example, I'll assume it's available in AccountingProvider or you pass it.
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // final currentUserId = authProvider.userId;
      // If AccountingProvider manages its own currentUserId:
      final currentUserId = accountingProvider.allTransactions.isNotEmpty
          ? accountingProvider.allTransactions.first.userId // Hacky way to get a user ID if provider not fully setup
          : "default_user"; // Fallback, replace with actual user ID logic

      if (currentUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User ID not available. Cannot save transaction.")),
        );
        return;
      }


      final newOrUpdatedTransaction = FinancialTransaction(
        id: widget.transaction?.id ?? _uuid.v4(),
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _selectedDate,
        category: _selectedCategory,
        userId: widget.transaction?.userId ?? currentUserId, // Use existing or current
      );

      if (_isEditing) {
        accountingProvider.updateTransaction(newOrUpdatedTransaction);
      } else {
        accountingProvider.addTransaction(newOrUpdatedTransaction);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountingProvider = Provider.of<AccountingProvider>(context, listen: false);
    final categories = _selectedType == TransactionType.income
        ? accountingProvider.incomeCategories
        : accountingProvider.expenseCategories;

    // Ensure _selectedCategory is valid for the current _selectedType
    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: _submitForm,
            tooltip: "Save",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Transaction Type Toggle
              SegmentedButton<TransactionType>(
                segments: const <ButtonSegment<TransactionType>>[
                  ButtonSegment<TransactionType>(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward)),
                  ButtonSegment<TransactionType>(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward)),
                ],
                selected: <TransactionType>{_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = null; // Reset category when type changes
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedForegroundColor: _selectedType == TransactionType.income
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  selectedBackgroundColor: _selectedType == TransactionType.income
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title / Source',
                  hintText: 'e.g., Salary, Groceries, Client Project',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: NumberFormat.simpleCurrency(locale: 'en_US').currencySymbol + ' ', // Adjust locale
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline)
                ),
                title: Text(
                    "Date: ${DateFormat.yMMMd().format(_selectedDate)}"), // Format as you like
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text('Select a category (Optional)'),
                isExpanded: true,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                // validator: (value) => value == null ? 'Please select a category' : null, // Optional: make category mandatory
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add any extra notes here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: Text(_isEditing ? 'Update Transaction' : 'Add Transaction'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}