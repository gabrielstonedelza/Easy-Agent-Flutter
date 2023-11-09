import 'package:flutter_local_notifications/flutter_local_notifications.dart';

<<<<<<< HEAD
class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // notificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings("ic_launcher");
    var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future<void> showNotifications(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("CHANNEL_ID", "CHANNEL_NAME",
=======
class LocalNotificationController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("ic_launcher");

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("CHANNEL_ID", "CHANNEL_NAME",
>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: "ic_launcher",
<<<<<<< HEAD
            sound: RawResourceAndroidNotificationSound("alertsound"));
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    return notificationsPlugin.show(0, title, body, notificationDetails);
  }
=======
            sound: RawResourceAndroidNotificationSound("alertsound")),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotifications(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return flutterLocalNotificationsPlugin.show(
        0, title, body, await notificationDetails());
  }
>>>>>>> 93087fe64ab5a4ec61eebb7826edd9c3cef64d34
}
