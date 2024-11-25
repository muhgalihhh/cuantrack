import 'package:cuantrack/controllers/google_auth.dart';
import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:cuantrack/services/theme_services.dart';
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
  final FirebaseTransactionController _firebaseTransactionController = FirebaseTransactionController();

  bool _isLoading = false; // Untuk indikasi loading saat logout
  List<Map<String, dynamic>> _transactions = []; // List transaksi
  late double _totalBalance = 0.0; // Total balance
  late double _totalExpense = 0.0; // Total expense
  late Map<String, dynamic> _progressData = {'value': 0.0, 'color': Colors.green, 'message': ''}; // Data progres

  // Inisialisasi data
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load Balances dan Expenses dari FireStore
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _firebaseTransactionController.fetchTransactions();

      setState(() {
        _transactions = transactions;
        _totalBalance = _firebaseTransactionController.calculateBalance(transactions);
        _totalExpense = transactions
          .where((transaction) => transaction['type'] == 'expense')
          .fold(0.0, (sum, transaction) => sum + (transaction['amount'] ?? 0.0));
        _progressData = _firebaseTransactionController.calculateProgress(_totalExpense, _totalBalance);
      });

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

  // Fungsi untuk menampilkan opsi transaksi
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
                  Navigator.pop(context); // Tutup bottom sheet
                  _showAddIncomeDialog(); // Tampilkan dialog Pemasukan
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove, color: Colors.red),
                title: const Text('Pengeluaran'),
                onTap: () {
                  Navigator.pop(context); // Tutup bottom sheet
                  _showAddExpenseDialog(); // Tampilkan dialog Pengeluaran
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan dialog AddIncomeDialog
  void _showAddIncomeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const AddIncomeDialog(), // Pastikan AddIncomeDialog sudah benar didefinisikan
    );
  }

  // Menampilkan dialog AddExpenseDialog
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const AddExpenseDialog(), // Pastikan AddExpenseDialog sudah benar didefinisikan
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CuanTrack'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ThemeService().switchTheme();
            },
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

      // Bottom Navigation Bar - Menggunakan NavigationMenu
      bottomNavigationBar: const NavigationMenu(),

      // Floating Action Button untuk menambah transaksi
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionOptions,
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Helper: Transaction Item Builder
  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryTile('Total Balance', _firebaseTransactionController.formatCurrency(_totalBalance), Colors.green),
          _buildSummaryTile('Total Expense', _firebaseTransactionController.formatCurrency(_totalExpense), Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
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
                backgroundColor: Colors.grey[300],
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
          style: TextStyle(color: _progressData['color'], fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(child: Text('Belum ada Transaksi'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final typeColor = transaction['type'] == 'income' ? Colors.green : Colors.red;
        DateTime transactionDate = transaction['date'];
        String formattedDate = _firebaseTransactionController.formatDate(transactionDate);
        
        return ListTile(
          leading: Icon(transaction['type'] == 'income' ? Icons.add : Icons.remove, color: typeColor),
          title: Text(transaction['category'] ?? 'Tidak ada Kategori'),
          subtitle: Text(formattedDate),
          trailing: Text(
            _firebaseTransactionController.formatCurrency(transaction['amount']),
            style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
          ),
        );
      },
    );
  }
}
