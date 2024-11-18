import 'package:cuantrack/controllers/google_auth.dart';
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
  bool _isLoading = false; // Untuk indikasi loading saat logout

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
              // Greeting Section
              Text(
                'Hi, Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // tampilkan nama user
              Text(
                _firebaseService.currentUser?.displayName ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Balance Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total Balance',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$7,783.00',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    // Total Expense
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total Expense',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '-\$1,187.40',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Expense Progress Section
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('30%',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '30% of your expenses. Looks good!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Transaction List Section
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(
                    title: index == 0
                        ? 'Salary'
                        : index == 1
                            ? 'Groceries'
                            : 'Rent',
                    subtitle: index == 0
                        ? '18:27 - April 30'
                        : index == 1
                            ? '17:00 - April 24'
                            : '8:30 - April 15',
                    amount: index == 0
                        ? '\$4,000.00'
                        : index == 1
                            ? '-\$100.00'
                            : '-\$674.40',
                    color: index == 0 ? Colors.green : Colors.red,
                    icon: Icons.account_balance_wallet,
                  );
                },
              ),
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
}
