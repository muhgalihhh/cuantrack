import 'package:cuantrack/controllers/analysis_cotroller.dart';
import 'package:cuantrack/views/widgets/categorypie_chart.dart';
import 'package:cuantrack/views/widgets/financial_chart.dart';
import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAnalysisController _analysisController =
      FirebaseAnalysisController();

  late TabController _tabController;
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _endDate = DateTime.now();
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _summaryFuture = _fetchFinancialData();
  }

  Future<Map<String, dynamic>> _fetchFinancialData() async {
    return await _analysisController.fetchCategorizedSummary(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _summaryFuture = _fetchFinancialData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analysis'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary', icon: Icon(Icons.dashboard)),
            Tab(text: 'Income', icon: Icon(Icons.trending_up)),
            Tab(text: 'Expense', icon: Icon(Icons.trending_down)),
          ],
          labelColor: Colors.white, // Active text color
          unselectedLabelColor: Colors.grey.shade300,
          indicatorColor: Colors.white, // Active indicator color
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No data available for the selected range.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(data),
              _buildCategoryTab(
                  'Income by Category', data['incomeByCategory'], true),
              _buildCategoryTab(
                  'Expense by Category', data['expenseByCategory'], false),
            ],
          );
        },
      ),
      bottomNavigationBar: const NavigationMenu(),
    );
  }

  Widget _buildSummaryTab(Map<String, dynamic> data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDateRangeHeader(),
        const SizedBox(height: 16),
        _buildSummaryCards(data),
        const SizedBox(height: 24),
        _buildTrendSection(data['trendData']),
      ],
    );
  }

  Widget _buildDateRangeHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text('Date Range:'),
              ],
            ),
            Text(
              '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Row(
      children: [
        _buildSummaryCard(
          'Total Income',
          data['totalIncome'],
          Theme.of(context).primaryColor,
          Icons.arrow_upward,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'Total Expense',
          data['totalExpense'],
          Theme.of(context).colorScheme.error,
          Icons.arrow_downward,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendSection(List<dynamic> trendData) {
    if (trendData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No trend data available for the selected period.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Financial Trend',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: FinancialTrendChart(
                trendData: trendData,
                context: context,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Income', Theme.of(context).primaryColor),
                const SizedBox(width: 24),
                _buildLegendItem(
                    'Expense', Theme.of(context).colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(
      String title, Map<String, dynamic> data, bool isIncome) {
    // Agregasikan data kategori
    final aggregatedData = _aggregateCategoryData(data);

    final Color primaryColor = isIncome
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.error;

    if (aggregatedData.isEmpty ||
        !aggregatedData.values.any((value) => value > 0)) {
      return const Center(
        child: Text(
          'No data available for this category',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isIncome ? Icons.trending_up : Icons.trending_down,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                SizedBox(
                  height: 300,
                  child: CategoryPieChart(
                    categoryData:
                        aggregatedData, // Menggunakan data yang sudah diagregasi
                    isIncome: isIncome,
                    context: context,
                  ),
                ),
                CategoryPieChart(
                  categoryData:
                      aggregatedData, // Menggunakan data yang sudah diagregasi
                  isIncome: isIncome,
                  context: context,
                ).buildCategoryLegend(),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Fungsi untuk mengagregasikan data kategori
  Map<String, double> _aggregateCategoryData(Map<String, dynamic> data) {
    final Map<String, double> aggregatedData = {};

    data.forEach((key, value) {
      if (value > 0) {
        aggregatedData[key] = (aggregatedData[key] ?? 0) + value;
      }
    });

    return aggregatedData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
