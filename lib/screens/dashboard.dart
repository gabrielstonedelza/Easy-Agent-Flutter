import 'dart:async';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
import 'package:easy_agent/screens/notifications.dart';
import 'package:easy_agent/screens/summaries/balancingsummary.dart';
import 'package:easy_agent/screens/summaries/bankdepositsummary.dart';
import 'package:easy_agent/screens/summaries/bankwithdrawalsummary.dart';
import 'package:easy_agent/screens/summaries/momocashinsummary.dart';
import 'package:easy_agent/screens/summaries/momowithdrawsummary.dart';
import 'package:easy_agent/screens/summaries/paymentsummary.dart';
import 'package:easy_agent/screens/trialandnotpaid/makepayment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/payto/agent.dart';
import 'package:easy_agent/screens/payto/merchant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import '../about.dart';
import '../controllers/authphonecontroller.dart';
import '../controllers/localnotificationcontroller.dart';
import '../controllers/notificationcontroller.dart';
import '../controllers/profilecontroller.dart';
import '../controllers/trialandmonthlypaymentcontroller.dart';
import '../widgets/loadingui.dart';
import 'accounts/myaccounts.dart';
import 'agent/agentaccount.dart';
import 'authenticatebyphone.dart';
import 'chats/groupchat.dart';
import 'customers/customeraccounts.dart';
import 'customers/mycustomers.dart';
import 'customers/registercustomer.dart';
import 'floats.dart';
import 'fraud.dart';
import 'login.dart';
import 'package:badges/badges.dart' as badges;

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
  bool needsToMakePayment = false;
  late List accountBalanceDetailsToday = [];

  Future<void> fetchAccountBalance() async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_started_today/";
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
      accountBalanceDetailsToday.assignAll(allPosts);
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
    final requestUrl = "https://fnetagents.xyz/user_read_notifications/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
    });
    if (response.statusCode == 200) {}
  }

  updateReadNotification(int id) async {
    final requestUrl = "https://fnetagents.xyz/user_read_notifications/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "read": "Read",
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
  late List myFreeTrialStatus = [];
  late List myMonthlyPaymentStatus = [];
  bool freeTrialEnded = false;
  bool monthEnded = false;
  late String endingDate = "";

  Future<void> fetchFreeTrial() async {
    const postUrl = "https://fnetagents.xyz/get_my_free_trial/";
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
      myFreeTrialStatus.assignAll(allPosts);
      for(var i in myFreeTrialStatus){
        freeTrialEnded = i['trial_ended'];
        setState(() {
          endingDate = i['end_date'];
        });
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }
  Future<void> fetchMonthlyPayment() async {
    const postUrl = "https://fnetagents.xyz/get_my_monthly_payment_status/";
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
      myMonthlyPaymentStatus.assignAll(allPosts);
      for(var i in myMonthlyPaymentStatus){
        monthEnded = i['month_ended'];
      }

      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }

  }

  // }
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

    fetchFreeTrial();
    fetchAccountBalance();
    fetchMonthlyPayment();
    notificationsController.getAllNotifications(uToken);
    notificationsController.getAllUnReadNotifications(uToken);
    profileController.getUserDetails(uToken);
    profileController.getUserProfile(uToken);
    getAllTriggeredNotifications();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      getAllTriggeredNotifications();
      notificationsController.getAllNotifications(uToken);
      notificationsController.getAllUnReadNotifications(uToken);
      getAllUnReadNotifications();
      for (var i in triggered) {
        localNotificationManager.showNotifications(
            i['notification_title'], i['notification_message']);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      // fetchFreeTrial();
      // fetchMonthlyPayment();
      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });
    localNotificationManager
        .setOnShowNotificationReceive(onNotificationReceive);
  }

  onNotificationReceive(ReceiveNotification notification) {}

  logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
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
  Widget build(BuildContext context) {
    return isLoading ? const LoadingUi() : freeTrialEnded && monthEnded ? const MakeMonthlyPayment() : phoneNotAuthenticated
        ?  AdvancedDrawer(
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
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: const Text(
                            'App created by Havens Software Development'),
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
                title: Text(agentCode,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: secondaryColor,
                actions: [
                  // IconButton(onPressed: () {  }, icon: const Icon(Icons.notifications),)
                  Padding(
                    padding: const EdgeInsets.only(right: 23.0),
                    child: Row(
                      children: [
                        GetBuilder<NotificationController>(
                            builder: (controller) {
                          return badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(top: -10, end: -12),
                            showBadge: true,
                            badgeContent: Text(
                                controller.notificationsUnread.length
                                    .toString(),
                                style: const TextStyle(color: defaultWhite)),
                            badgeAnimation:
                                const badges.BadgeAnimation.rotation(
                              animationDuration: Duration(seconds: 1),
                              colorChangeAnimationDuration:
                                  Duration(seconds: 1),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                              colorChangeAnimationCurve: Curves.easeInCubic,
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const Notifications());
                                },
                                child: const Icon(Icons.notifications)),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
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
                                                Image.asset(
                                                  "assets/images/boy.png",
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text("Agent",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )
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
                                                Image.asset(
                                                  "assets/images/cashier.png",
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10.0),
                                                  child: Text("Merchant",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
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
                            accountBalanceDetailsToday.isNotEmpty ?
                            Get.to(() => const MomoCashInSummary()) : Get.snackbar("Account balance error", "Please add account balance for today",
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
                            accountBalanceDetailsToday.isNotEmpty ? Get.to(() => const MomoCashOutSummary()) :Get.snackbar("Account balance error", "Please add account balance for today",
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
                          onTap: () {
                            DeviceApps.openApp("com.wMY247KIOSK_15547762");
                            // showMaterialModalBottomSheet(
                            //   context: context,
                            //   builder: (context) => Card(
                            //     elevation: 12,
                            //     shape: const RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.only(
                            //             topRight: Radius.circular(10),
                            //             topLeft: Radius.circular(10))),
                            //     child: SizedBox(
                            //       height: 150,
                            //       child: Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           const Center(
                            //               child: Text("Select",
                            //                   style: TextStyle(
                            //                       fontWeight: FontWeight.bold))),
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceEvenly,
                            //             children: [
                            //               GestureDetector(
                            //                 onTap: () {
                            //                   Get.to(() => const Airtime());
                            //                   // Get.back();
                            //                 },
                            //                 child: Column(
                            //                   children: [
                            //                     Image.asset(
                            //                       "assets/images/telephone-call.png",
                            //                       width: 50,
                            //                       height: 50,
                            //                     ),
                            //                     const Padding(
                            //                       padding: EdgeInsets.only(top: 10.0),
                            //                       child: Text("Airtime",
                            //                           style: TextStyle(
                            //                               fontWeight: FontWeight.bold)),
                            //                     )
                            //                   ],
                            //                 ),
                            //               ),
                            //               GestureDetector(
                            //                 onTap: () {
                            //                   Get.to(() => const PayToMerchant());
                            //                 },
                            //                 child: Column(
                            //                   children: [
                            //                     Image.asset(
                            //                       "assets/images/internet.png",
                            //                       width: 50,
                            //                       height: 50,
                            //                     ),
                            //                     const Padding(
                            //                       padding: EdgeInsets.only(top: 10.0),
                            //                       child: Text("Internet Bundle",
                            //                           style: TextStyle(
                            //                               fontWeight: FontWeight.bold)),
                            //                     )
                            //                   ],
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // );
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
                            openFinancialServices();
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
                              const Text("Payment"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const PaymentSummary());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/law.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Balancing"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const BalancingSummary());
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/exchanging.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Floats"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const Floats());
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
                                "assets/images/fraud-alert.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Fraud"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => const Fraud());
                          },
                        ),
                      ),
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
                            Get.to(() => const GroupChat());
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
                            accountBalanceDetailsToday.isNotEmpty ? Get.to(() => const MyAccountDashboard()) :Get.snackbar("Account balance error", "Please add account balance for today",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              floatingActionButton: !freeTrialEnded ? FloatingActionButton(
                backgroundColor:defaultWhite,
                onPressed: (){
                  Get.defaultDialog(
                      buttonColor: secondaryColor,
                      title: "Trial Alert",
                      content: Column(
                        children: [
                          Text("You are using a trial version of Easy Agent which is ending on ${tpController.endingDate}")
                        ],
                      )
                  );
                },
                child: Image.asset("assets/images/freetrial.png"),
              ):Container(),
            )
    )
        :
    Scaffold(
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
