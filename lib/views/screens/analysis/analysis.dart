import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Analysis Screen'),
      ),
      bottomNavigationBar: const NavigationMenu(),
    );
  }
}
