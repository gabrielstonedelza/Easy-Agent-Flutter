
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/rxdart.dart';

// class LocalNotificationManager{
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   var initSetting;
//   BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject => BehaviorSubject<ReceiveNotification>();
//
//   initializePlatform(){
//     var initSettingAndroid = const AndroidInitializationSettings("forapp");
//     initSetting = InitializationSettings(android: initSettingAndroid,);
//     // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//     //     AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
//   }
//
//   LocalNotificationManager.init(){
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     initializePlatform();
//   }
//
//   setOnNotificationReceive(Function onNotificationReceive){
//     didReceiveLocalNotificationSubject.listen((notification) {
//       onNotificationReceive(notification);
//     });
//   }
//
//   Future<void> showNotifications(String? title,String? body) async{
//     var androidChannel = const AndroidNotificationDetails(
//         "CHANNEL_ID",
//         "CHANNEL_NAME",
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound("alertsound")
//     );
//
//     var platformChannel = NotificationDetails(android: androidChannel);
//     await flutterLocalNotificationsPlugin.show(0,title,body,platformChannel,payload: "New Payload");
//   }
//   setOnShowNotificationReceive(Function onNotificationReceive){
//     didReceiveLocalNotificationSubject.listen((notification) {
//       onNotificationReceive(notification);
//     });
//   }
//   // setOnShowNotificationClick(Function onNotificationClick)async{
//   //   await flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
//   //     onNotificationClick(payload);
//   //   });
//   // }
// }
//
// LocalNotificationManager localNotificationManager = LocalNotificationManager.init();
//
// class ReceiveNotification{
//   final int? id;
//   final String? title;
//   final String? body;
//   final String? payload;
//   ReceiveNotification({required this.id,required this.title,required this.body,required this.payload});
// }

class NotificationService{
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification()async{
    notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
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