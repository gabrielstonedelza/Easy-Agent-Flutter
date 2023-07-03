import 'package:easy_agent/screens/payments/unpaidrequests.dart';
import 'package:easy_agent/screens/summaries/balancingsummary.dart';
import 'package:easy_agent/screens/summaries/paymentsummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/basicui.dart';

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
                      myBasicWidget("cash-payment.png","Payment","/ Re-Balancing"),
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
                      myBasicWidget("digital-wallet.png","Unpaid","Requests"),
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
                      myBasicWidget("balance.png","Re-Balancing","Summary"),
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
