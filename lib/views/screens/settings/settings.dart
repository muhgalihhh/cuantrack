import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Profile Screen'),
      ),
      bottomNavigationBar: const NavigationMenu(),
    );
  }
}
