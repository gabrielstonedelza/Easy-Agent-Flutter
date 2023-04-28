
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telephony/telephony.dart';
import 'package:get/get.dart';

import 'constants.dart';
import 'controllers/agentcontroller.dart';
import 'controllers/customerscontroller.dart';
import 'controllers/logincontroller.dart';
import 'controllers/notificationcontroller.dart';
import 'controllers/profilecontroller.dart';
import 'newsplash.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  Get.put(LoginController());
  Get.put(ProfileController());
  Get.put(CustomersController());
  Get.put(AgentController());
  Get.put(NotificationController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
      Get.defaultDialog(
          content: Column(
            children: [
              Text(_message)
            ],
          ),
          confirm: TextButton(
            onPressed: (){
              Get.back();
            },
            child: const Text("OK",style:TextStyle(fontWeight:FontWeight.bold)),
          )
      );
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }



    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.leftToRight,
      theme: ThemeData(
        primaryColor: secondaryColor,
        appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: secondaryColor,
        )
      ),
      home: const SplashScreen(),
    );
  }
}


