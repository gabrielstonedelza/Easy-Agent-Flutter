import 'dart:async';

import 'package:easy_agent/screens/payto/agent.dart';
import 'package:easy_agent/screens/payto/merchant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'cashincashout/cashin.dart';
import 'cashout.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Timer _timer;
  Future<void> openFinancialServices(String bankNum) async {
    await UssdAdvanced.multisessionUssd(
        code: "*171*6*1*1*$bankNum#", subscriptionId: 1);
  }

  SmsQuery query = SmsQuery();
  late List mySmss = [];
  int lastSmsCount = 0;

  fetchInbox()async {
    List<SmsMessage> messages = await query.getAllSms;
    for (var message in messages) {
      if(message.address == "MobileMoney") {
        if(!mySmss.contains(message.body)){
          mySmss.add(message.body);
        }
      }
    }
    // print(mySmss);
  }
  // }
  Future checkMtnBalance() async {
    fetchInbox();
    Get.defaultDialog(
        content: Column(
          children: [
            Text(mySmss.first)
          ],
        ),
        confirm: TextButton(
          onPressed: (){
            Get.back();
          },
          child: const Text("OK",style:TextStyle(fontWeight:FontWeight.bold)),
        )
    );
  }

  @override
  void initState(){
    super.initState();
    fetchInbox();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
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
                                          fontWeight: FontWeight.bold))),
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
                                          padding: EdgeInsets.only(top: 10.0),
                                          child: Text("Agent",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => const PayToMerchant());
                                    },
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/cashier.png",
                                          width: 50,
                                          height: 50,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 10.0),
                                          child: Text("Merchant",
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
                    Get.to(() => const CashIn());
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
                    Get.snackbar("Hiii 😃😃", "Coming Soon",
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.amber);
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
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => Card(
                        elevation: 12,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10))),
                        child: SizedBox(
                          height: 155,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                  child: Text("Select Bank",
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
                                      openFinancialServices("4");
                                      // Get.back();
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
                                    onTap: () {
                                      openFinancialServices("7");
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
                                  GestureDetector(
                                    onTap: () {
                                      openFinancialServices("5");
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
                                          child: Text("Fidelity",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      openFinancialServices("8");
                                    },
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/ecomobile-card.png",
                                          width: 50,
                                          height: 50,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 10.0),
                                          child: Text("Ecobank",
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
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //             Image.asset("assets/images/bill.png",width: 70,height: 70,),
          //             const SizedBox(height: 10,),
          //             const Text("Pay Bill"),
          //           ],
          //         ),
          //         onTap: (){
          //
          //         },
          //       ),
          //     ),
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //
          //           ],
          //         ),
          //         onTap: (){
          //
          //         },
          //       ),
          //     ),
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //
          //           ],
          //         ),
          //         onTap: (){
          //
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
