import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAnalysisController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> incomeCategoriesList = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Lainnya',
  ];

  final List<String> expenseCategoriesList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> fetchCategorizedSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final String userId = user.uid;

      final userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        throw Exception('User not found');
      }

      final userData = userSnapshot.data();
      if (userData == null || !userData.containsKey('balanceHistory')) {
        throw Exception('Balance history data is missing or invalid');
      }

      final balanceHistory = userData['balanceHistory'] as List<dynamic>?;

      if (balanceHistory == null || balanceHistory.isEmpty) {
        return {
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'averageIncome': 0.0,
          'averageExpense': 0.0,
          'incomeByCategory': {for (var cat in incomeCategoriesList) cat: 0.0},
          'expenseByCategory': {
            for (var cat in expenseCategoriesList) cat: 0.0
          },
          'trendData': [],
          'message': 'No transactions found in the selected date range.',
        };
      }

      // Normalize startDate and endDate for inclusive filtering
      DateTime normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      DateTime normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      // Initialize category-based aggregates
      Map<String, double> incomeByCategory = {
        for (var category in incomeCategoriesList) category: 0.0
      };
      Map<String, double> expenseByCategory = {
        for (var category in expenseCategoriesList) category: 0.0
      };

      double totalIncome = 0;
      double totalExpense = 0;
      int incomeCount = 0;
      int expenseCount = 0;

      List<Map<String, dynamic>> trendData = [];

      // Process balance history
      for (var entry in balanceHistory) {
        final amount = entry['amount'] as double?;
        final type = entry['type'] as String?;
        final category = entry['category'] as String?;
        final dateTimestamp = entry['date'] as Timestamp?;

        if (amount == null ||
            type == null ||
            category == null ||
            dateTimestamp == null) {
          // Skip entry if any critical data is null
          continue;
        }

        final date = dateTimestamp.toDate();

        // Debugging: Print transaction details
        print('Transaction Date: $date');
        print('Start Date: $normalizedStartDate');
        print('End Date: $normalizedEndDate');
        print(
            'Condition: ${!date.isBefore(normalizedStartDate) && !date.isAfter(normalizedEndDate)}');

        // Filter by date range (inclusive)
        if (!date.isBefore(normalizedStartDate) &&
            !date.isAfter(normalizedEndDate)) {
          if (type == 'income') {
            totalIncome += amount;
            incomeCount++;
            incomeByCategory[category] =
                (incomeByCategory[category] ?? 0) + amount;
          } else if (type == 'expense') {
            totalExpense += amount.abs(); // Ensure positive for visualization
            expenseCount++;
            expenseByCategory[category] =
                (expenseByCategory[category] ?? 0) + amount.abs();
          }

          // Trend data
          trendData.add({
            'date': date.toIso8601String(),
            'amount': amount,
            'type': type,
          });
        }
      }

      if (trendData.isEmpty) {
        return {
          'totalIncome': totalIncome,
          'totalExpense': totalExpense,
          'averageIncome': incomeCount > 0 ? totalIncome / incomeCount : 0,
          'averageExpense': expenseCount > 0 ? totalExpense / expenseCount : 0,
          'incomeByCategory': incomeByCategory,
          'expenseByCategory': expenseByCategory,
          'trendData': [],
          'message': 'No transactions found in the selected date range.',
        };
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'averageIncome': incomeCount > 0 ? totalIncome / incomeCount : 0,
        'averageExpense': expenseCount > 0 ? totalExpense / expenseCount : 0,
        'incomeByCategory': incomeByCategory,
        'expenseByCategory': expenseByCategory,
        'trendData': trendData,
      };
    } catch (e) {
      throw Exception('Failed to fetch categorized summary: $e');
    }
  }
}
