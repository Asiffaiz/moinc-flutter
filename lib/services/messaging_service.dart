import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:moinc/services/local_notification_service.dart';

class MessagingServices {
  MessagingServices() {
    _configureFCMListeners();
    NotificationService.initialize();
  }

  void _configureFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming data message when the app is in the foreground
      if (kDebugMode) {
        print("Data message received: ${message.notification!.title}");
      }

      if (message.notification != null) {
        NotificationService.showSimpleNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle incoming data message when the app is in the background or terminated
      if (kDebugMode) {
        print("Data message opened: ${message.notification!.title}}");
      }

      if (message.notification != null) {
        NotificationService.showSimpleNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
      // try {
      //   if (message != null) {
      //     handleNotificationNavigation(message.data);
      //   }
      // } catch (e) {
      //   if (kDebugMode) {
      //     print(e);
      //   }
      // }
    });
  }
}
