import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/payments/unpaidrequests.dart';
import 'package:easy_agent/screens/summaries/balancingsummary.dart';
import 'package:easy_agent/screens/summaries/paymentsummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                        "assets/images/cash-payment.png",
                        width: 70,
                        height: 70,
                      ),
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
                      Image.asset(
                        "assets/images/law.png",
                        width: 70,
                        height: 70,
                      ),
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
