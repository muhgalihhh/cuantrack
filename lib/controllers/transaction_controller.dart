import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirebaseTransactionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cek apakah pengguna sudah terautentikasi
  User? get currentUser => _auth.currentUser;

  // Add Income
  Future<void> addIncome({
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('transactions').add({
        'type': 'income',
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date), // Pake timestamp untuk mengurangi inconsistencies
        'notes': notes ?? '',
        'userId': user.uid, // Menyimpan ID pengguna
      });
    } catch (e) {
      throw Exception('Failed to add income: $e');
    }
  }

  // Add Expense
  Future<void> addExpense({
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('transactions').add({
        'type': 'expense',
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date), // Pake timestamp untuk mengurangi inconsistencies
        'notes': notes ?? '',
        'userId': user.uid, // Menyimpan ID pengguna
      });
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Fetch Transactions for the authenticated user
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();
      
      // Convert snapshot ke List<Map<String, dynamic>>
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'date': (data['date'] as Timestamp).toDate(), // Convert timestamp ke DateTime
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Format currency
  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 2);
    return formatter.format(value);
  }

  // Format DateTime
  String formatDate(DateTime dateTime, {String format = 'dd-MM-yyyy HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  // Hitung saldo
  double calculateBalance(List<Map<String, dynamic>> transactions) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        income += transaction['amount'];
      } else if (transaction['type'] == 'expense') {
        expense += transaction['amount'];
      }
    }

    return income - expense;
  }

  // Hitung progres
  Map<String, dynamic> calculateProgress(double expense, double balance) {
    final value = balance == 0 ? 0 : (expense / balance);
    Color color;
    String message;

    // Pesan
    if (expense == 0) {
      color = Colors.blue;
      message = 'Belum ada pengeluaran.';
    } else if (expense < balance * 0.25) {
      color = Colors.green;
      message = 'Pengeluaran terkontrol.';
    } else if (expense < balance * 0.5) {
      color = Colors.lightGreen;
      message = 'Bagus! Terus jaga pengeluaran.';
    } else if (expense < balance * 0.75) {
      color = Colors.orange;
      message = 'Hati-hati! Pengeluaran mulai tinggi.';
    } else if (expense <= balance) {
      color = Colors.deepOrange;
      message = 'Pengeluaran hampir mencapai batas!';
    } else {
      color = Colors.red;
      message = 'Pengeluaran terlalu besar!';
    }

    return {
      'value': value,
      'color': color,
      'message': message,
    };
  }
}
