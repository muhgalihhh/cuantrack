import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:flutter/material.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({Key? key}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final FirebaseTransactionController _firebaseService = FirebaseTransactionController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];
  String? _selectedCategory;

  Future<void> _saveExpense() async {
    if (_isLoading) return;

    if (_selectedCategory == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kateogri dan jumlah harus diisi')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus berupa angka')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseService.addExpense(
        category: _selectedCategory!,
        amount: amount,
        date: _selectedDate,
        notes: notes,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil disimpan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengeluaran: $e')),
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Catatan (opsional)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                child: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Simpan'),
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
