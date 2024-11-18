import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: Center(
          child: Text('Transaction Screen'),
        ),
      ),
      bottomNavigationBar: const NavigationMenu(),
    );
  }
}
