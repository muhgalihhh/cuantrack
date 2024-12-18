import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuantrack/controllers/google_auth.dart';
import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:cuantrack/services/theme_service.dart';
import 'package:cuantrack/views/widgets/add_expense.dart';
import 'package:cuantrack/views/widgets/add_income.dart';
import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseTransactionController _transactionController =
      FirebaseTransactionController();

  bool _isLoading = false;
  Map<String, List<Map<String, dynamic>>> _transactions = {};
  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  Map<String, dynamic> _progressData = {
    'value': 0.0,
    'color': Colors.green,
    'message': ''
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupedTransactions =
          await _transactionController.fetchTransactions();

      double totalBalance = 0.0;
      double totalExpense = 0.0;

      // Debugging: print the fetched transactions
      print('Fetched Transactions: $groupedTransactions');

      groupedTransactions.forEach((key, group) {
        for (var transaction in group) {
          if (transaction['type'] == 'income') {
            totalBalance += transaction['amount'];
          } else if (transaction['type'] == 'expense') {
            totalBalance -= transaction['amount'];
            totalExpense += transaction['amount'];
          }
        }
      });

      double progressValue = totalExpense > 0
          ? (totalExpense / (totalExpense + totalBalance)).clamp(0.0, 1.0)
          : 0.0;

      String progressMessage;
      Color progressColor;

      if (progressValue >= 0.7) {
        progressMessage = 'Warning: High Expenses!';
        progressColor = Colors.red;
      } else if (progressValue >= 0.4) {
        progressMessage = 'Manage Your Expenses Wisely';
        progressColor = Colors.orange;
      } else {
        progressMessage = 'Expenses Under Control!';
        progressColor = Colors.green;
      }

      setState(() {
        _transactions = groupedTransactions;
        _totalBalance = totalBalance;
        _totalExpense = totalExpense;
        _progressData = {
          'value': progressValue,
          'color': progressColor,
          'message': progressMessage,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTransactionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: Colors.green),
                title: const Text('Pemasukan'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddIncomeDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove, color: Colors.red),
                title: const Text('Pengeluaran'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddExpenseDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddIncomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddIncomeDialog(),
    ).then((_) => _loadData());
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddExpenseDialog(),
    ).then((_) => _loadData());
  }

  Future<void> _handleLogout() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CuanTrack'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ThemeService().switchTheme(),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildGreetingSection(),
              const SizedBox(height: 16),
              _buildBalanceSummary(),
              const SizedBox(height: 16),
              _buildExpenseProgress(),
              const SizedBox(height: 24),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavigationMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionOptions,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, Welcome Back',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          _firebaseService.currentUser?.displayName ?? '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildBalanceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryTile(
              'Total Balance', _formatCurrency(_totalBalance), Colors.green),
          _buildSummaryTile(
              'Total Expense', _formatCurrency(_totalExpense), Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildExpenseProgress() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: _progressData['value'],
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                color: _progressData['color'],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(_progressData['value'] * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _progressData['message'],
          style: TextStyle(
              color: _progressData['color'], fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return const Center(child: Text('Belum ada Transaksi'));
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (_transactions['Today']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Today',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (_transactions['Today']?.isNotEmpty ?? false)
          ..._transactions['Today']!.map((transaction) {
            final typeColor =
                transaction['type'] == 'income' ? Colors.green : Colors.red;

            return ListTile(
              leading: Icon(
                transaction['type'] == 'income' ? Icons.add : Icons.remove,
                color: typeColor,
              ),
              title: Text(transaction['category'] ?? 'Tidak ada Kategori'),
              subtitle: Text(_formatDate(transaction['date'])),
              trailing: Text(
                _formatCurrency(transaction['amount']),
                style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
              ),
            );
          }).toList(),
        if (_transactions['Yesterday']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Yesterday',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (_transactions['Yesterday']?.isNotEmpty ?? false)
          ..._transactions['Yesterday']!.map((transaction) {
            final typeColor =
                transaction['type'] == 'income' ? Colors.green : Colors.red;

            return ListTile(
              leading: Icon(
                transaction['type'] == 'income' ? Icons.add : Icons.remove,
                color: typeColor,
              ),
              title: Text(transaction['category'] ?? 'Tidak ada Kategori'),
              subtitle: Text(_formatDate(transaction['date'])),
              trailing: Text(
                _formatCurrency(transaction['amount']),
                style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
              ),
            );
          }).toList(),
        if (_transactions['Previous Days']?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Previous Days',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (_transactions['Previous Days']?.isNotEmpty ?? false)
          ..._transactions['Previous Days']!.map((transaction) {
            final typeColor =
                transaction['type'] == 'income' ? Colors.green : Colors.red;

            return ListTile(
              leading: Icon(
                transaction['type'] == 'income' ? Icons.add : Icons.remove,
                color: typeColor,
              ),
              title: Text(transaction['category'] ?? 'Tidak ada Kategori'),
              subtitle: Text(_formatDate(transaction['date'])),
              trailing: Text(
                _formatCurrency(transaction['amount']),
                style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
              ),
            );
          }).toList(),
      ],
    );
  }

  String _formatDate(Timestamp date) {
    final dateTime = date.toDate();
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today - ${dateTime.hour}:${dateTime.minute}';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday - ${dateTime.hour}:${dateTime.minute}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatCurrency(double amount) {
    // Memisahkan bagian bulat dan desimal
    final parts = amount.toStringAsFixed(0).split('');

    // Membalik string untuk mempermudah penambahan titik
    final reversed = parts.reversed.toList();

    // Menambahkan titik setiap 3 digit
    final formatted = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      formatted.add(reversed[i]);
      if ((i + 1) % 3 == 0 && i != reversed.length - 1) {
        formatted.add('.');
      }
    }

    // Membalik kembali dan menambahkan prefix Rp
    return 'Rp ${formatted.reversed.join()}';
  }
}
