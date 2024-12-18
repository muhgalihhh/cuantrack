import 'package:cuantrack/services/notifications.dart';
import 'package:cuantrack/services/theme_service.dart';
import 'package:cuantrack/views/widgets/navigation_menu.dart';
import 'package:cuantrack/views/widgets/profile_edit_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _selectedReminderTime;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _notificationService.init();
    await _loadSavedReminderTime();
  }

  Future<void> _loadSavedReminderTime() async {
    final savedTime = await _notificationService.getSavedReminderTime();
    if (savedTime != null && mounted) {
      setState(() {
        _selectedReminderTime = savedTime;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    try {
      // Check and request permission first
      final bool hasPermission =
          await _notificationService.handleReminderPermission(context);

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Notifications permission is required to set reminders'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedReminderTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                hourMinuteShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                dayPeriodShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        await _notificationService.scheduleReminderNotification(pickedTime);

        if (mounted) {
          setState(() {
            _selectedReminderTime = pickedTime;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reminder set for ${pickedTime.format(context)}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to set reminder. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error setting reminder: $e');
    }
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      // Cancel all notifications when logging out
      await _notificationService.cancelAllNotifications();
      Get.offAllNamed('/login');
    }
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? color,
    Widget? trailing,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ThemeService().switchTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _currentUser?.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                    child: _currentUser?.photoURL == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.displayName ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentUser?.email ?? 'No email',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Preferences Section
              _buildSettingsSection(
                title: 'Preferences',
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Daily Reminder',
                    subtitle: _selectedReminderTime != null
                        ? 'Set for ${_selectedReminderTime!.format(context)}'
                        : 'Not set',
                    onTap: _selectReminderTime,
                    trailing: _selectedReminderTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () async {
                              await _notificationService
                                  .cancelAllNotifications();
                              setState(() {
                                _selectedReminderTime = null;
                              });
                            },
                          )
                        : const Icon(Icons.chevron_right),
                  ),
                  _buildSettingsTile(
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: Get.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    onTap: () => ThemeService().switchTheme(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Account Section
              _buildSettingsSection(
                title: 'Account',
                children: [
                  _buildSettingsTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ProfileEditModal(),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavigationMenu(),
    );
  }
}
