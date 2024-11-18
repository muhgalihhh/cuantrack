import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:flutter/material.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({Key? key}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final FirebaseTransactionController _firebaseService =
      FirebaseTransactionController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _saveExpense() async {
    if (_isLoading) return;

    final category = _categoryController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    if (category.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category and amount are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseService.addExpense(
        category: category,
        amount: amount,
        date: _selectedDate,
        notes: notes,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save expense: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                child: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show the modal dialog
Future<void> showAddExpenseDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => const AddExpenseDialog(),
  );
}
