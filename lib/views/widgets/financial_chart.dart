import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialTrendChart extends StatefulWidget {
  final List<dynamic> trendData;
  final BuildContext context;

  const FinancialTrendChart({
    Key? key,
    required this.trendData,
    required this.context,
  }) : super(key: key);

  @override
  State<FinancialTrendChart> createState() => _FinancialTrendChartState();
}

class _FinancialTrendChartState extends State<FinancialTrendChart> {
  List<FlSpot> _generateSpots(String type) {
    final filteredData =
        widget.trendData.where((entry) => entry['type'] == type).toList();

    if (filteredData.isEmpty) return [];

    final List<FlSpot> spots = [];
    for (var i = 0; i < filteredData.length; i++) {
      final amount = filteredData[i]['amount'] as double;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final incomeSpots = _generateSpots('income');
    final expenseSpots = _generateSpots('expense')
        .map((spot) => FlSpot(spot.x, spot.y.abs()))
        .toList();

    if (incomeSpots.isEmpty && expenseSpots.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Tambah ruang untuk label
              interval: _getXAxisInterval(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.trendData.length) {
                  final date = DateTime.parse(widget.trendData[index]['date']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('d MMM').format(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Tambah ruang untuk label
              interval: _calculateHorizontalInterval(),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    NumberFormat.compact().format(value),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: widget.trendData.length.toDouble() - 1,
        minY: 0,
        maxY: _calculateMaxY(),
        lineBarsData: [
          // Income Line
          if (incomeSpots.isNotEmpty)
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),

          // Expense Line
          if (expenseSpots.isNotEmpty)
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Theme.of(context).colorScheme.error,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }

  // Metode untuk mendapatkan interval sumbu x yang sesuai
  double _getXAxisInterval() {
    final length = widget.trendData.length;

    // Jika data sedikit, tampilkan semua label
    if (length <= 5) return 1;

    // Jika data banyak, tampilkan 5-6 label
    return (length / 5).ceil().toDouble();
  }

  // Calculate horizontal grid interval dynamically
  double _calculateHorizontalInterval() {
    final allAmounts = widget.trendData
        .map((entry) => (entry['amount'] as double).abs())
        .toList();

    if (allAmounts.isEmpty) return 10000;

    final maxAmount = allAmounts.reduce((a, b) => a > b ? a : b);

    // Create more granular intervals based on max amount
    if (maxAmount < 50000) return 5000;
    if (maxAmount < 100000) return 10000;
    if (maxAmount < 500000) return 25000;
    if (maxAmount < 1000000) return 50000;

    return 100000;
  }

  // Calculate max Y value for chart scaling
  double _calculateMaxY() {
    final amounts = widget.trendData
        .map((entry) => (entry['amount'] as double).abs())
        .toList();

    if (amounts.isEmpty) return 10000;

    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    // Add some padding
    return maxAmount * 1.2;
  }
}
