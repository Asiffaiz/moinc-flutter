import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static void initialize(BuildContext context) {
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           iOS: DarwinInitializationSettings(), //YOU JUST HAVE TO ADD THIS
//           android: AndroidInitializationSettings("@mipmap/launcher_icon"),
//         );

//     _notificationsPlugin.initialize(initializationSettings);
//   }

//   static void display(RemoteMessage message) async {
//     // Define the BigTextStyleInformation

//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       NotificationDetails notificationDetails = const NotificationDetails(
//         android: AndroidNotificationDetails(
//           "Moinc",
//           "moinc-channel",
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       );

//       await _notificationsPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//         // payload: message.data["route"],
//       );
//     } on Exception catch (e) {
//       if (kDebugMode) print(e);
//     }
//   }

//   static displayCustom(int id, String title, String body) async {
//     // Define the BigTextStyleInformation

//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       NotificationDetails notificationDetails = const NotificationDetails(
//         android: AndroidNotificationDetails(
//           "Moinc",
//           "moinc-channel",
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       );

//       await _notificationsPlugin.show(
//         id,
//         title,
//         body,
//         notificationDetails,
//         // payload: message.data["route"],
//       );
//     } on Exception catch (e) {
//       if (kDebugMode) print(e);
//     }
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped with payload: ${response.payload}');
      },
    );

    tz.initializeTimeZones();
  }

  //           "Moinc",
  //           "moinc-channel",
  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'moinc-channel',
        'Moinc Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // 1️⃣ Simple Notification
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      0,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  // 2️⃣ Scheduled Notification
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exact,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 3️⃣ Repeating Notification
  static Future<void> repeatNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.periodicallyShow(
      2,
      title,
      body,
      RepeatInterval.everyMinute,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  // 4️⃣ Cancel Notification
  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // 5️⃣ Cancel All
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  // 6️⃣ Show Notification When App in Foreground
  static Future<void> showForegroundNotification() async {
    await _notificationsPlugin.show(
      3,
      'Moinc',
      'Moinc is in foreground',
      _notificationDetails(),
    );
  }
}
