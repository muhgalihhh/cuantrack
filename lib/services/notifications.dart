import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// NotificationService is a singleton service class to handle
/// notification permissions, scheduling, and reminder management.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Android notification settings
  final AndroidInitializationSettings _androidSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS notification settings
  final DarwinInitializationSettings _iOSSettings =
      const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  static const String _reminderTimeKey =
      'reminder_time'; // SharedPreferences key
  bool _initialized = false; // Tracks if the service is initialized

  /// Check if notification permission is granted
  Future<bool> checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return true; // iOS handled differently
  }

  /// Request notification permission from the user
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize timezone support
      tz.initializeTimeZones();

      // Define platform-specific initialization settings
      final InitializationSettings initSettings = InitializationSettings(
        android: _androidSettings,
        iOS: _iOSSettings,
      );

      // Initialize the plugin
      final bool? success = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (success ?? false) {
        _initialized = true;

        // Check for saved reminder time and reschedule if exists
        final savedTime = await getSavedReminderTime();
        if (savedTime != null) {
          final bool hasPermission = await checkNotificationPermission();
          if (hasPermission) {
            await scheduleReminderNotification(savedTime);
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Handle notification permission dialog
  Future<bool> handleReminderPermission(BuildContext context) async {
    try {
      final bool hasPermission = await checkNotificationPermission();

      if (!hasPermission) {
        // Show dialog explaining why permission is needed
        final bool shouldRequest = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Notification Permission'),
                content: const Text(
                    'To set reminders, we need permission to send notifications. '
                    'Would you like to enable notifications?'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Not Now'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldRequest) {
          final permissionGranted = await requestNotificationPermission();
          return permissionGranted;
        }
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error handling notification permission: $e');
      return false;
    }
  }

  /// Save reminder time in SharedPreferences
  Future<void> saveReminderTime(TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = '${time.hour}:${time.minute}';
      await prefs.setString(_reminderTimeKey, timeString);
    } catch (e) {
      debugPrint('Error saving reminder time: $e');
      rethrow;
    }
  }

  /// Retrieve saved reminder time from SharedPreferences
  Future<TimeOfDay?> getSavedReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_reminderTimeKey);

      if (timeString != null) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);

          if (hour != null && minute != null) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved reminder time: $e');
      return null;
    }
  }

  /// Schedule daily reminder notification
  Future<void> scheduleReminderNotification(TimeOfDay time) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      // Save the reminder time
      await saveReminderTime(time);

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminders',
        channelDescription: 'Channel for daily reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notifications.zonedSchedule(
        0,
        'CuanTrack!',
        'Don\'t forget to track your expenses today!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Reminder scheduled for ${time.hour}:${time.minute}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Add navigation or other actions here when notification is tapped
  }

  /// Cancel all notifications and clear saved time
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reminderTimeKey);
      debugPrint('All notifications canceled');
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
      rethrow;
    }
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }
}
