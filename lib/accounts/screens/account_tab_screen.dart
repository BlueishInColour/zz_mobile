// screens/account_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/account_models.dart';
import '../providers/accounting_provider.dart';
import 'add_edit_transactions_screen.dart'; // We'll create this next

class AccountTabScreen extends StatefulWidget {
  const AccountTabScreen({Key? key}) : super(key: key);

  @override
  State<AccountTabScreen> createState() => _AccountTabScreenState();
}

class _AccountTabScreenState extends State<AccountTabScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming currentUserId is set in the provider when the app starts
    // or through some auth mechanism that updates the provider.
    // If not, you might need to trigger setting it here if it's the first time.
    // Example:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //   Provider.of<AccountingProvider>(context, listen: false).setCurrentUserId(authProvider.userId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final accountingProvider = Provider.of<AccountingProvider>(context);
    final summary = accountingProvider.getAccountSummary();
    final transactions = accountingProvider.allTransactions; // Or separate lists

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$'); // Adjust locale & symbol

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
        centerTitle: true,
      ),
      body: accountingProvider.isLoading && transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => accountingProvider.loadTransactions(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSummaryCard(context, summary, currencyFormat),
            const SizedBox(height: 20),
            _buildSectionHeader(context, "Recent Transactions"),
            if (transactions.isEmpty && !accountingProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Center(
                    child: Text("No transactions yet. Tap '+' to add one!",
                        style: TextStyle(fontSize: 16, color: Colors.grey))),
              )
            else
              ...transactions.take(10).map((tx) => TransactionListItem( // Display first 10 or implement pagination/tabs
                transaction: tx,
                currencyFormat: currencyFormat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTransactionScreen(transaction: tx),
                    ),
                  );
                },
              )).toList(),
            // Potentially add "View All Transactions" button here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(), // For adding a new one
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Entry"),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AccountSummary summary, NumberFormat currencyFormat) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Income:", style: TextStyle(fontSize: 16)),
                Text(currencyFormat.format(summary.totalIncome),
                    style: TextStyle(fontSize: 16, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Expenses:", style: TextStyle(fontSize: 16)),
                Text(currencyFormat.format(summary.totalExpenses),
                    style: TextStyle(fontSize: 16, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Net Balance:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(summary.netBalance),
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: summary.netBalance >= 0 ? Colors.blue.shade800 : Colors.orange.shade900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final FinancialTransaction transaction;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.currencyFormat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isIncome ? Colors.green : Colors.red,
          size: 28,
        ),
        title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            "${transaction.category ?? 'Uncategorized'} - ${DateFormat.yMMMd().format(transaction.date)}"),
        trailing: Text(
          "${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}",
          style: TextStyle(
            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onTap: onTap, // To view/edit details
      ),
    );
  }
}