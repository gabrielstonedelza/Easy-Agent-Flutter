
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/rxdart.dart';

class NotificationService{
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification()async{
    // notificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings("ic_launcher");
    var initializationSettingsIOS = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse: (NotificationResponse notificationResponse)async{

    });
  }

  Future<void> showNotifications({int id=0,String? title,String? body,String? payLoad}) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        icon: "ic_launcher",
        sound: RawResourceAndroidNotificationSound("alertsound")
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    return notificationsPlugin.show(0, title, body, notificationDetails);
  }

}