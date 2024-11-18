import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        'date': date,
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
        'date': date,
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
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }
}
