import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTransactionController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cek apakah pengguna sudah terautentikasi
  User? get currentUser => _auth.currentUser;

  // Update user balance with more detailed tracking
  Future<void> _updateUserBalance(
      double amount, String type, String category, DateTime? date) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userDoc = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentData = snapshot.data() ?? {};
      final currentBalance = (currentData['balance'] ?? 0.0) as double;
      final currentTotalIncome = (currentData['totalIncome'] ?? 0.0) as double;
      final currentTotalExpense =
          (currentData['totalExpense'] ?? 0.0) as double;
      final currentBalanceHistory =
          List<Map<String, dynamic>>.from(currentData['balanceHistory'] ?? []);

      final updatedBalanceHistory = [
        ...currentBalanceHistory.take(49), // Batasi maksimal 50 item
        {
          'amount': amount,
          'type': type,
          'category': category,
          'date': date ?? FieldValue.serverTimestamp(),
        },
      ];

      transaction.set(
          userDoc,
          {
            'balance': currentBalance + amount,
            'totalIncome': type == 'income'
                ? currentTotalIncome + amount
                : currentTotalIncome,
            'totalExpense': type == 'expense'
                ? currentTotalExpense + amount
                : currentTotalExpense,
            'lastUpdated': FieldValue.serverTimestamp(),
            'balanceHistory': updatedBalanceHistory,
          },
          SetOptions(merge: true)); // Gunakan merge untuk menghindari overwrite
    });
  }

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
      print('Adding income...');
      // Tambah transaksi
      await _firestore.collection('transactions').add({
        'type': 'income',
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'notes': notes ?? '',
        'userId': user.uid,
      });
      print('Income added to transactions.');

      // Update balance dengan tipe 'income'
      await _updateUserBalance(amount, 'income', category, date);
    } catch (e) {
      print('Error adding income: $e');
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
      print('Adding expense...');
      // Tambah transaksi
      await _firestore.collection('transactions').add({
        'type': 'expense',
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'notes': notes ?? '',
        'userId': user.uid,
      });
      print('Expense added to transactions.');

      // Update balance dengan tipe 'expense'
      await _updateUserBalance(-amount, 'expense', category, date);
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchTransactions() async {
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

      if (snapshot.docs.isEmpty) {
        return {}; // If there are no transactions
      }

      // Process grouping
      Map<String, List<Map<String, dynamic>>> groupedTransactions = {
        'Today': [],
        'Yesterday': [],
        'Previous Days': [],
      };

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 365));
      DateTime twoDaysAgo = now.subtract(const Duration(days: 2));

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Convert Timestamp to DateTime
        DateTime transactionDate = (data['date'] as Timestamp).toDate();

        if (_isSameDay(transactionDate, now)) {
          groupedTransactions['Today']?.add({'id': doc.id, ...data});
        } else if (_isSameDay(transactionDate, yesterday)) {
          groupedTransactions['Yesterday']?.add({'id': doc.id, ...data});
        } else if (transactionDate.isAfter(sevenDaysAgo) &&
            transactionDate.isBefore(twoDaysAgo)) {
          groupedTransactions['Previous Days']?.add({'id': doc.id, ...data});
        }
      }

      print('Transactions fetched: $groupedTransactions');

      return groupedTransactions;
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Fungsi untuk membandingkan apakah dua tanggal adalah hari yang sama
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Fetch user balance details
  Future<Map<String, dynamic>> getUserBalanceDetails() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('Fetching user balance details...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('User balance document does not exist.');
        return {
          'balance': 0.0,
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'lastUpdated': null,
          'balanceHistory': []
        };
      }

      final data = userDoc.data()!;
      print('User balance details fetched: $data');
      return {
        'balance': data['balance'] ?? 0.0,
        'totalIncome': data['totalIncome'] ?? 0.0,
        'totalExpense': data['totalExpense'] ?? 0.0,
        'lastUpdated': data['lastUpdated'],
        'balanceHistory': data['balanceHistory'] ?? []
      };
    } catch (e) {
      print('Error fetching balance details: $e');
      throw Exception('Failed to fetch balance details: $e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> filteredFetch({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return {}; // If there are no transactions within the filtered range
      }

      // Process grouping
      Map<String, List<Map<String, dynamic>>> groupedTransactions = {
        'Today': [],
        'Yesterday': [],
        'Previous Days': [],
      };

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      DateTime sevenDaysAgo = now.subtract(const Duration(days: 365));

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime transactionDate = (data['date'] as Timestamp).toDate();

        if (_isSameDay(transactionDate, now)) {
          groupedTransactions['Today']?.add({'id': doc.id, ...data});
        } else if (_isSameDay(transactionDate, yesterday)) {
          groupedTransactions['Yesterday']?.add({'id': doc.id, ...data});
        } else if (transactionDate.isAfter(sevenDaysAgo)) {
          groupedTransactions['Previous Days']?.add({'id': doc.id, ...data});
        }
      }
      print('Filtered transactions fetched: $groupedTransactions');
      return groupedTransactions;
    } catch (e) {
      throw Exception('Failed to fetch filtered transactions: $e');
    }
  }
}
