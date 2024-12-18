import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuantrack/controllers/transaction_controller.dart';
import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final FirebaseTransactionController _transactionController =
      FirebaseTransactionController();

  Map<String, List<Map<String, dynamic>>> _transactions = {};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialTransactions();
  }

  // Format currency dalam Rupiah
  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final reversed = parts.reversed.toList();

    final formatted = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      formatted.add(reversed[i]);
      if ((i + 1) % 3 == 0 && i != reversed.length - 1) {
        formatted.add('.');
      }
    }

    return 'Rp ${formatted.reversed.join()}';
  }

  // Fetch transaksi awal
  Future<void> _fetchInitialTransactions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final initialTransactions =
          await _transactionController.fetchTransactions();
      setState(() {
        _transactions = _groupTransactionsByDate(initialTransactions);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching transactions: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memilih rentang tanggal
  Future<void> _selectDateRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
      await _fetchFilteredTransactions(pickedRange.start, pickedRange.end);
    }
  }

  // Fetch transaksi berdasarkan filter tanggal
  Future<void> _fetchFilteredTransactions(
      DateTime startDate, DateTime endDate) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final filteredTransactions = await _transactionController.filteredFetch(
        startDate: startDate,
        endDate: endDate
            .add(const Duration(days: 1))
            .subtract(Duration(milliseconds: 1)),
      );
      setState(() {
        _transactions = _groupTransactionsByDate(filteredTransactions);
      });
    } catch (e) {
      setState(() {
        _transactions = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching filtered transactions: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kelompokkan transaksi berdasarkan tanggal
  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate(
      Map<String, List<Map<String, dynamic>>> transactions) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    transactions.forEach((key, value) {
      for (var transaction in value) {
        DateTime date = (transaction['date'] as Timestamp).toDate();
        String dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!groupedTransactions.containsKey(dateKey)) {
          groupedTransactions[dateKey] = [];
        }
        groupedTransactions[dateKey]?.add(transaction);
      }
    });

    return groupedTransactions;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_startDate != null && _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Showing transactions from ${_formatDate(_startDate!)} to ${_formatDate(_endDate!)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transactions.keys.length,
                            itemBuilder: (context, index) {
                              String dateKey =
                                  _transactions.keys.elementAt(index);
                              return _buildTransactionGroup(
                                  dateKey, _transactions[dateKey]!);
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavigationMenu(),
    );
  }

  // Build tampilan kelompok transaksi
  Widget _buildTransactionGroup(
      String title, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index];
            DateTime transactionDate =
                (transaction['date'] as Timestamp).toDate();
            return ListTile(
              title: Text(
                transaction['category'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_formatCurrency(transaction['amount'])} - ${_formatDate(transactionDate)}',
                style: TextStyle(
                  color: transaction['type'] == 'income'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              trailing: Icon(
                transaction['type'] == 'income' ? Icons.add : Icons.remove,
                color:
                    transaction['type'] == 'income' ? Colors.green : Colors.red,
              ),
            );
          },
        ),
      ],
    );
  }
}
