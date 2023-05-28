import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/payments/unpaidrequests.dart';
import 'package:easy_agent/screens/summaries/balancingsummary.dart';
import 'package:easy_agent/screens/summaries/paymentsummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/getonlineimage.dart';

class PaymentAndReBalancing extends StatefulWidget {
  const PaymentAndReBalancing({Key? key}) : super(key: key);

  @override
  State<PaymentAndReBalancing> createState() => _PaymentAndReBalancingState();
}

class _PaymentAndReBalancingState extends State<PaymentAndReBalancing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment & ReBalancing"),
        backgroundColor: secondaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2331/2331941.png",70,70),
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
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2331/2331941.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Unpaid Request"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const UnPaidRequests());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/994/994377.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("ReBalancing"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const BalancingSummary());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
