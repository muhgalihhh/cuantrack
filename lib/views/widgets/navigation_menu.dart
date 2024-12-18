import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyimpan selectedIndex untuk menandakan tab yang aktif
    final int _selectedIndex = Get.currentRoute == '/home'
        ? 0
        : Get.currentRoute == '/transactions'
            ? 1
            : Get.currentRoute == '/analysis'
                ? 2
                : 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Warna latar belakang NavigationBar
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), // Rounded pada sudut kiri atas
          topRight: Radius.circular(50), // Rounded pada sudut kanan atas
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Bayangan untuk elevasi
            blurRadius: 10,
            offset: const Offset(0, -2), // Arah bayangan ke atas
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex, // Menetapkan index yang dipilih
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/home');
              break;
            case 1:
              Get.toNamed('/transactions');
              break;
            case 2:
              Get.toNamed('/analysis');
              break;
            case 3:
              Get.toNamed('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
