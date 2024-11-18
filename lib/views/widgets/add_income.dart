import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:flutter/material.dart';

class AddIncomeDialog extends StatefulWidget {
  const AddIncomeDialog({Key? key}) : super(key: key);

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final FirebaseTransactionController _firebaseService =
      FirebaseTransactionController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _saveIncome() async {
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
      await _firebaseService.addIncome(
        category: category,
        amount: amount,
        date: _selectedDate,
        notes: notes,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save income: $e')),
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
                onPressed: _isLoading ? null : _saveIncome,
                child: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Save Income'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show the modal dialog
Future<void> showAddIncomeDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => const AddIncomeDialog(),
  );
}
