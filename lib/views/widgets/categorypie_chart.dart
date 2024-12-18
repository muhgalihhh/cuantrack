import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, dynamic> categoryData;
  final bool isIncome;
  final BuildContext context;

  const CategoryPieChart({
    Key? key,
    required this.categoryData,
    required this.isIncome,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aggregate category data
    final aggregatedData = _aggregateCategoryData(categoryData);

    // Filter out categories with zero value
    final filteredData = aggregatedData.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (filteredData.isEmpty) {
      return const Center(
        child: Text('No category data available'),
      );
    }

    final Color primaryColor = isIncome
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.error;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: filteredData.map((entry) {
                final percentage =
                    (entry.value / _calculateTotal(filteredData)) * 100;
                return PieChartSectionData(
                  color: _generateColorVariant(
                      primaryColor, filteredData.indexOf(entry)),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Aggregate category data by summing values of the same category
  Map<String, double> _aggregateCategoryData(Map<String, dynamic> data) {
    final Map<String, double> aggregatedData = {};

    data.forEach((key, value) {
      if (aggregatedData.containsKey(key)) {
        aggregatedData[key] = aggregatedData[key]! + (value as double);
      } else {
        aggregatedData[key] = (value as double);
      }
    });

    return aggregatedData;
  }

  double _calculateTotal(List<MapEntry<String, double>> entries) {
    return entries.fold(0, (sum, entry) => sum + entry.value);
  }

  Color _generateColorVariant(Color baseColor, int index) {
    // Generate color variants for each category
    final hsvColor = HSVColor.fromColor(baseColor);
    final variant =
        hsvColor.withValue((hsvColor.value - (index * 0.1)).clamp(0.0, 1.0));
    return variant.toColor();
  }

  Widget buildCategoryLegend() {
    final filteredData = categoryData.entries
        .where((entry) => entry.value > 0)
        .map((entry) =>
            MapEntry(entry.key, entry.value as double)) // Pastikan tipe double
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Color primaryColor = isIncome
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.error;

    final totalValue = _calculateTotal(filteredData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredData.map((entry) {
        final percentage = (entry.value / totalValue) * 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _generateColorVariant(
                      primaryColor, filteredData.indexOf(entry)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${entry.value.toStringAsFixed(1)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
