import 'dart:async';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
import 'package:easy_agent/screens/payto/agent.dart';
import 'package:easy_agent/screens/payto/merchant.dart';
import 'package:easy_agent/screens/reports/addreport.dart';
import 'package:easy_agent/screens/summaries/allsummaries.dart';
import 'package:easy_agent/screens/summaries/bankdepositsummary.dart';
import 'package:easy_agent/screens/summaries/bankwithdrawalsummary.dart';
import 'package:easy_agent/screens/summaries/momocashinsummary.dart';
import 'package:easy_agent/screens/summaries/momowithdrawsummary.dart';
import 'package:easy_agent/screens/summaries/paytosummary.dart';
import 'package:easy_agent/screens/summaries/reportsummary.dart';

import 'package:easy_agent/widgets/getonlineimage.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import '../about.dart';
import '../controllers/authphonecontroller.dart';
import '../controllers/localnotificationcontroller.dart';
import '../controllers/notificationcontroller.dart';
import '../controllers/profilecontroller.dart';
import '../controllers/trialandmonthlypaymentcontroller.dart';
import '../widgets/basicui.dart';
import 'agent/agentaccount.dart';
import 'authenticatebyphone.dart';
import 'bank/bankdeposit.dart';
import 'bank/bankwithdrawal.dart';
import 'calculatecurrency.dart';
import 'calculatedenominations.dart';
import 'cashincashout/cashin.dart';
import 'cashincashout/cashout.dart';
import 'chats/agents_group_chat.dart';
import 'chats/myowneragents.dart';
import 'chats/privatechat.dart';
import 'commissions.dart';
import 'customers/customeraccounts.dart';
import 'customers/mycustomers.dart';
import 'customers/registercustomer.dart';
import 'customerservice/customerservice.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class TimeChecker {
  static Timer? _timer;

  static void startTimer(BuildContext context) {
    stopTimer(); // Stop any existing timers before starting a new one

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      // Get the current local time zone
      String localTimeZone = await FlutterNativeTimezone.getLocalTimezone();

      // Get the current date and time
      DateTime now = DateTime.now().toUtc();


      // Convert the current time to the local time zone
      DateTime localTime = now.toLocal();

      // Check if the local time is 8:00
      if (localTime.hour == 12) {
        // Stop the timer
        stopTimer();
        // Navigate to the login page
        Get.offAll(() => const LoginView());
      }
    });
  }

  static void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

class _DashboardState extends State<Dashboard> {
  DateTime now = DateTime.now();
  NotificationController notificationsController = Get.find();
  final ProfileController profileController = Get.find();
  final storage = GetStorage();
  late String uToken = "";
  late String agentCode = "";
  late Timer _timer;
  bool isLoading = true;
  Future<void> openFinancialServices() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*1#", subscriptionId: 1);
  }

  Future<void> openFinancialServicesPullFromBank() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*2#", subscriptionId: 1);
  }


  final _advancedDrawerController = AdvancedDrawerController();
  SmsQuery query = SmsQuery();
  late List mySmss = [];
  int lastSmsCount = 0;
  late List allNotifications = [];

  late List yourNotifications = [];

  late List notRead = [];

  late List triggered = [];

  late List unreadNotifications = [];

  late List triggeredNotifications = [];

  late List notifications = [];

  late List allNots = [];
  bool phoneNotAuthenticated = false;
  final AuthPhoneController authController = Get.find();
  final TrialAndMonthlyPaymentController tpController = Get.find();

  bool isAuthenticated = false;
  bool isAuthenticatedAlready = false;
  late List accountBalanceDetailsClosedToday = [];
  bool hasClosedAccountToday = false;

  Future<void> fetchAccountBalanceClosed() async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_closed_today/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      accountBalanceDetailsClosedToday.assignAll(allPosts);
      for(var i in accountBalanceDetailsClosedToday){
        if(i['date_closed'] == now.toString().split(" ").first && i['isClosed'] == true){
          hasClosedAccountToday = true;
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }

  Future<void> getAllTriggeredNotifications() async {
    const url = "https://fnetagents.xyz/get_triggered_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      triggeredNotifications = json.decode(jsonData);
      triggered.assignAll(triggeredNotifications);
    }
  }

  Future<void> getAllUnReadNotifications() async {
    const url = "https://fnetagents.xyz/get_my_unread_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
      notRead.assignAll(yourNotifications);
    }
  }

  Future<void> getAllNotifications() async {
    const url = "https://fnetagents.xyz/get_my_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allNotifications = json.decode(jsonData);
      allNots.assignAll(allNotifications);
    }
  }

  unTriggerNotifications(int id) async {
    final requestUrl = "https://fnetagents.xyz/un_trigger_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
      "read": "Read",
    });
    if (response.statusCode == 200) {}
  }

  updateReadNotification(int id) async {
    const requestUrl = "https://fnetagents.xyz/read_notification/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
    });
    if (response.statusCode == 200) {}
  }

  fetchInbox() async {
    List<SmsMessage> messages = await query.getAllSms;
    for (var message in messages) {
      if (message.address == "MobileMoney") {
        if (!mySmss.contains(message.body)) {
          mySmss.add(message.body);
        }
      }
    }
    // print(mySmss);
  }
  Future<void> fetchAllInstalled() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true,includeAppIcons: false);
    // if (kDebugMode) {
    //   print(apps);
    // }
  }
  void showInstalled() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Card(
        elevation: 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10))),
        child: SizedBox(
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text("Continue with mtn's financial services",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      openFinancialServices();
                      // Get.back();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Push USSD",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DeviceApps.openApp('com.mtn.agentapp');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("MTN App",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      openFinancialServicesPullFromBank();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Pull USSD",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text("Continue with apps",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.ecobank.xpresspoint');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/xpresspoint.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Express Point",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('sg.android.fidelity');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/fidelity-card.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Fidelity Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('calbank.com.ams');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/calbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Cal Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('accessmob.accessbank.com.accessghana');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/accessbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Access Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.m2i.gtexpressbyod');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/gtbank.jpg",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("GT Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('firstmob.firstbank.com.fbnsubsidiary');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/full-branch.jpg",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("FBN Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future checkMtnBalance() async {
    fetchInbox();
    Get.defaultDialog(
        content: Column(
          children: [Text(mySmss.first)],
        ),
        confirm: TextButton(
          onPressed: () {
            Get.back();
          },
          child:
              const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
        ));
  }
  late List allRequests = [];
  bool hasSomePendings = false;
  late List allPendingList = [];
  final Uri _url = Uri.parse('https://aop.ecobank.com/register');

  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  Future<void>fetchAllRequests()async{
    const url = "https://fnetagents.xyz/get_all_my_requests/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allRequests = json.decode(jsonData);
      for(var i in allRequests){
          allPendingList.add(i['request_approved']);
          allPendingList.add(i['request_paid']);
          allPendingList.add(i['payment_approved']);
      }
      setState(() {
        isLoading = false;
      });
    }
    if(allPendingList.contains("Pending")){
      setState(() {
        hasSomePendings = true;
      });
    }
    else{
      setState(() {
        hasSomePendings = false;
      });
    }
  }

  bool isLatestAppVersion = false;
  int appVersionNow = 7;
  late int appVersion = 0;
  late int appVersionFromServer = 0;
  late List appVersions = [];
  Future<void> getLatestAppVersion() async {
    const url = "https://fnetagents.xyz/check_app_version/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      appVersions.assignAll(jsonData);
      for(var i in appVersions){
        appVersion = i['app_version'];
        if(appVersionNow == appVersion){
          setState(() {
            isLatestAppVersion = true;
          });
        }
        else{
          setState(() {
            isLatestAppVersion = false;
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isClosingTimeNow = false;

  void checkTheTime(){
    var hour = DateTime.now().hour;
    switch (hour) {
      case 9:
        // setState(() {
        //   isClosingTimeNow = true;
        // });
        logoutUser();
        break;
    // case 01:
    //   setState(() {
    //     isMidNight = true;
    //   });
    //   break;
    // case 02:
    //   setState(() {
    //     isMidNight = true;
    //   });
    //   break;
    // case 03:
    //   setState(() {
    //     isMidNight = true;
    //   });
    //   break;
    // case 04:
    //   setState(() {
    //     isMidNight = false;
    //   });
    //   break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInbox();
    TimeChecker.startTimer(context);
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchInbox();
    });

    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }

    if (storage.read("phoneAuthenticated") != null) {
      setState(() {
        phoneNotAuthenticated = true;
      });
    }

    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }

    if (storage.read("AppVersion") != null) {
      setState(() {
        appVersionFromServer = int.parse(storage.read("AppVersion"));
      });
    }
    // checkTheTime();
    getLatestAppVersion();
    tpController.fetchFreeTrial(uToken);
    tpController.fetchAccountBalance(uToken);
    tpController.fetchMonthlyPayment(uToken);
    notificationsController.getAllNotifications(uToken);
    notificationsController.getAllUnReadNotifications(uToken);
    profileController.getUserDetails(uToken);
    profileController.getUserProfile(uToken);
    getAllTriggeredNotifications();
    fetchAllRequests();
    fetchAccountBalanceClosed();
    fetchAllInstalled();

// Clear existing timers before creating new ones
    _timer.cancel();

    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getAllTriggeredNotifications();
      getAllUnReadNotifications();
      tpController.fetchFreeTrial(uToken);
      tpController.fetchAccountBalance(uToken);
      tpController.fetchMonthlyPayment(uToken);

      for (var i in triggered) {
        NotificationService().showNotifications(
          title: i['notification_title'],
          body: i['notification_message'],
        );
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      getLatestAppVersion();
      // checkTheTime();

      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });
  }
  logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");
    storage.remove("IsAuthDevice");
    storage.remove("AppVersion");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetagents.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      storage.remove("token");
      storage.remove("agent_code");
      storage.remove("AppVersion");
      Get.offAll(() => const LoginView());
    }
  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return   phoneNotAuthenticated ?  AdvancedDrawer(
            backdropColor: snackBackground,
            controller: _advancedDrawerController,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            animateChildDecoration: true,
            rtlOpening: false,
            // openScale: 1.0,
            disabledGestures: false,
            childDecoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            drawer: SafeArea(
              child: ListTileTheme(
                textColor: Colors.white,
                iconColor: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 140.0,
                      height: 140.0,
                      margin: const EdgeInsets.only(
                        top: 24.0,
                        bottom: 64.0,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/forapp.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Version: 1.1.2",
                        style: TextStyle(
                            fontSize: 20,
                            color: defaultWhite,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(
                      color: secondaryColor,
                    ),
                    ListTile(
                      onTap: () {
                        Get.to(() => const AboutPage());
                      },
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                    ),
                    ListTile(
                      onTap: () {
                        Get.defaultDialog(
                            buttonColor: primaryColor,
                            title: "Confirm Logout",
                            middleText: "Are you sure you want to logout?",
                            confirm: RawMaterialButton(
                                shape: const StadiumBorder(),
                                fillColor: secondaryColor,
                                onPressed: () {
                                  logoutUser();
                                  Get.back();
                                },
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.white),
                                )),
                            cancel: RawMaterialButton(
                                shape: const StadiumBorder(),
                                fillColor: secondaryColor,
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                )));
                      },
                      leading: const Icon(Icons.logout_sharp),
                      title: const Text('Logout'),
                    ),
                    const Spacer(),
                    Container(
                      width: 140.0,
                      height: 140.0,
                      margin: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 14.0,
                      ),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/png.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                'App created by Havens Software Development'),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: _handleMenuButtonPressed,
                  icon: ValueListenableBuilder<AdvancedDrawerValue>(
                    valueListenable: _advancedDrawerController,
                    builder: (_, value, __) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          value.visible ? Icons.clear : Icons.menu,
                          key: ValueKey<bool>(value.visible),
                        ),
                      );
                    },
                  ),
                ),
                title: GetBuilder<ProfileController>(builder: (controller){
                  return Text(controller.agentUniqueCode,
                      style: const TextStyle(fontWeight: FontWeight.bold,color:secondaryColor));
                },),
                backgroundColor: snackBackground,
                actions: [
                  IconButton(
                    onPressed: (){
                      Get.to(() => const CalculateDenominations());
                    },
                    icon: myOnlineImage("accounting.png",30,30),
                  ),
                  IconButton(
                    onPressed: (){
                      Get.to(() => const AllSummaries());
                    },
                    icon: myOnlineImage("summaries.png",30,30),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: IconButton(
                      onPressed: (){
                        Get.to(() => const AddNewReport());
                      },
                      icon: myOnlineImage("market-analysis.png",30,30),
                    ),
                  )
                ],
              ),
              body: ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("payment-method.png","Pay To",""),
                              onTap: () {
                                showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => Card(
                                    elevation: 12,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10))),
                                    child: SizedBox(
                                      height: 150,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Center(
                                              child: Text("Select",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold))),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(() => const PayToAgent());
                                                  // Get.back();
                                                },
                                                child: Column(
                                                  children: [
                                                    myBasicWidget("employee.png","Agent",""),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                          () => const PayToMerchant());
                                                },
                                                child: Column(
                                                  children: [
                                                    myBasicWidget("cashier.png","Merchant",""),

                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("money-withdrawal.png","Cash In",""),

                              onTap: () {
                                Get.to(() => const CashIn());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("commission.png","Cash Out",""),
                              onTap: () {
                                Get.to(() => const CashOut());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("ecomobile-card.png","Ecobank","Accounts"),
                              onTap: () async{
                                await _launchInBrowser();
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("wallet.png","Wallet",""),

                              onTap: () {
                                checkMtnBalance();
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("employee.png","Agent","Accounts"),

                              onTap: () {
                                Get.to(() => const AgentAccounts());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("bank.png","Bank","Deposit"),

                              onTap: () {
                                Get.to(() => const BankDeposit());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("bank.png","Bank","Withdrawals"),

                              onTap: () {
                                Get.to(() => const BankWithdrawal());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("bank.png","Financial","Services"),

                              onTap: () {
                                showInstalled();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("group.png","Customer","Registration"),
                              onTap: () {
                                Get.to(() => const CustomerRegistration());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("group.png","Customer","Accounts"),

                              onTap: () {
                                Get.to(() => const CustomerAccountRegistration());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("group.png","My","Customers"),

                              onTap: () {
                                Get.to(() => const MyCustomers());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("conversation.png","Chat",""),

                              onTap: () {
                                showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => SizedBox(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top:25.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              child: Column(
                                                children: [
                                                  myBasicWidget("cashier.png","Owner",""),
                                                ],
                                              ),
                                              onTap: () {
                                                Get.to(()=> const PrivateChat());
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              child: Column(
                                                children: [
                                                  myBasicWidget("employee.png","Agent",""),
                                                ],
                                              ),
                                              onTap: () {
                                                Get.to(() => const AgentsGroupChat());
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              child: Column(
                                                children: [
                                                  myBasicWidget("employee.png","Agent","Private Chat"),
                                                ],
                                              ),
                                              onTap: () {
                                                Get.to(() => const AllOwnerUsers());
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("customer-cares.png","Customer","Service"),

                              onTap: () {
                                Get.to(() => const CustomerService());
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: myBasicWidget("commissions.png","Commissions",""),

                              onTap: () {
                                Get.to(() => const Commissions());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
            )
    ) : Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/images/96238-auth-failed.json"),
                const Center(
                  child: Text(
                    "Authentication Error",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: warning,
                        fontSize: 20),
                  ),
                ),
                const SizedBox(height: 50,),
                TextButton(
                  onPressed: () {
                    Get.offAll(() => const AuthenticateByPhone());
                  },
                  child: const Text("Authenticate",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                )
              ],
            ),

          );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}