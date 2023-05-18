import 'dart:async';
import 'dart:convert';

import 'package:easy_agent/join_screen.dart';
import 'package:easy_agent/screens/notifications.dart';
import 'package:easy_agent/screens/paymentandrebalancing.dart';
import 'package:easy_agent/screens/summaries/bankdepositsummary.dart';
import 'package:easy_agent/screens/summaries/bankwithdrawalsummary.dart';
import 'package:easy_agent/screens/summaries/momocashinsummary.dart';
import 'package:easy_agent/screens/summaries/momowithdrawsummary.dart';
import 'package:easy_agent/screens/summaries/paytosummary.dart';
import 'package:easy_agent/screens/summaries/requestsummary.dart';
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
import 'accounts/myaccounts.dart';
import 'agent/agentaccount.dart';
import 'authenticatebyphone.dart';
import 'chats/agentsGroupchat.dart';
import 'chats/privatechat.dart';
import 'commissions.dart';
import 'customers/customeraccounts.dart';
import 'customers/mycustomers.dart';
import 'customers/registercustomer.dart';
import 'customerservice/customerservice.dart';
import 'customerservice/fraud.dart';
import 'login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

  final Uri _url = Uri.parse('https://my247kiosk.com/');
  final Uri _expressUrl = Uri.parse('https://xpresspoint.ecobank.com/agencybankingWEB/');
  final Uri _fidelityWeb = Uri.parse('https://dpfbgl101.myfidelitybank.net:7101/solution.html');
  final Uri _calBankWeb = Uri.parse('https://ams.caleservice.net/');

  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
  Future<void> _launchInExpress() async {
    if (!await launchUrl(_expressUrl)) {
      throw 'Could not launch $_expressUrl';
    }
  }
  Future<void> _launchFidelityWeb() async {
    if (!await launchUrl(_fidelityWeb)) {
      throw 'Could not launch $_fidelityWeb';
    }
  }
  Future<void> _launchCalWeb() async {
    if (!await launchUrl(_calBankWeb)) {
      throw 'Could not launch $_calBankWeb';
    }
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
          height: 400,
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
                MainAxisAlignment.center,
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
                          child: Text("MTN",
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
                  child: Text("Continue on the web",
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
                      await _launchInExpress();
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
                      await _launchFidelityWeb();
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
                      await _launchCalWeb();
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

  @override
  void initState() {
    super.initState();
    fetchInbox();
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

    tpController.fetchFreeTrial(uToken);
    tpController.fetchAccountBalance(uToken);
    tpController.fetchMonthlyPayment(uToken);

    notificationsController.getAllNotifications(uToken);
    notificationsController.getAllUnReadNotifications(uToken);
    profileController.getUserDetails(uToken);
    profileController.getUserProfile(uToken);
    getAllTriggeredNotifications();
    fetchAllRequests();

    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getAllTriggeredNotifications();
      getAllUnReadNotifications();
      tpController.fetchFreeTrial(uToken);
      tpController.fetchAccountBalance(uToken);
      tpController.fetchMonthlyPayment(uToken);
      for (var i in triggered) {
        NotificationService().showNotifications(title:i['notification_title'], body:i['notification_message']);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });

  }


  logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");
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
                        "Version: 1.1.1",
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
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      child: Column(
                        children: const [
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
                      style: const TextStyle(fontWeight: FontWeight.bold));
                },),
                backgroundColor: secondaryColor,
                // actions: [
                //   IconButton(
                //     onPressed: (){
                //       Get.to(() => JoinScreen());
                //     },
                //     icon: Image.asset("assets/images/live-stream.png"),
                //   )
                // ],
              ),
              body:  ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/cash-on-delivery.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Pay To"),
                            ],
                          ),
                          onTap: () {
                            tpController.accountBalanceDetailsToday.isNotEmpty ?
                            hasSomePendings ? Get.snackbar("Request Error", "You have a request that is not paid or approved.",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: warning,
                              duration: const Duration(seconds: 5)
                            ):  Get.to(() => const PayToSummary()) : Get.snackbar("Account balance error", "Please add account balance for today",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                            // Get.to(() => const PayToSummary());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/money-withdrawal.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Cash In"),
                            ],
                          ),
                          onTap: () {
                            tpController.accountBalanceDetailsToday.isNotEmpty ?
                            hasSomePendings ? Get.snackbar("Request Error", "You have a request that is not paid or approved.",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: warning,
                                duration: const Duration(seconds: 5)
                            ):      Get.to(() => const MomoCashInSummary()) : Get.snackbar("Account balance error", "Please add account balance for today",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/commission1.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Cash Out"),
                            ],
                          ),
                          onTap: () {
                            tpController.accountBalanceDetailsToday.isNotEmpty ? hasSomePendings ? Get.snackbar("Request Error", "You have a request that is not paid or approved.",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: warning,
                                duration: const Duration(seconds: 5)
                            ): Get.to(() => const MomoCashOutSummary()) :Get.snackbar("Account balance error", "Please add account balance for today",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/telephone-call.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Airtime"),
                              const Text("&"),
                              const Text("Bundles"),
                            ],
                          ),
                          onTap: () async{
                            await _launchInBrowser();
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/wallet.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Wallet"),
                            ],
                          ),
                          onTap: () {
                            checkMtnBalance();
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/agent.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Agent"),
                              const Text("Accounts"),
                            ],
                          ),
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/bank.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Bank"),
                              const Text("Deposit"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const BankDepositSummary());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/bank.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Bank"),
                              const Text("Withdrawal"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const BankWithdrawalSummary());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/bank.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Financial"),
                              const Text("Services"),
                            ],
                          ),
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/group.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Customer"),
                              const Text("Registration"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const CustomerRegistration());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/group.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Customer"),
                              const Text("Accounts"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const CustomerAccountRegistration());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/group.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("My"),
                              const Text("Customers"),
                            ],
                          ),
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/cash-payment.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Payment &"),
                              const Text("Rebalancing"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const PaymentAndReBalancing());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/mywallet.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Accounts"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const MyAccountDashboard());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/ewallet.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Request"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const RequestSummary());
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/groupchat.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Chat"),
                            ],
                          ),
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
                                              Image.asset(
                                                "assets/images/cashier.png",
                                                width: 70,
                                                height: 70,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text("Owner"),
                                            ],
                                          ),
                                          onTap: () {
                                            Get.to(()=> PrivateChat());
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/images/team1.png",
                                                width: 70,
                                                height: 70,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text("Agent Chat"),
                                            ],
                                          ),
                                          onTap: () {
                                            Get.to(() => const AgentsGroupChat());
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
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/customer-care.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Customer"),
                              const Text("Service"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const CustomerService());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/commission.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Commissions"),
                            ],
                          ),
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