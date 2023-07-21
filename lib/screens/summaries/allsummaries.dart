import 'package:easy_agent/screens/summaries/paytosummary.dart';
import 'package:easy_agent/screens/summaries/reportsummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/basicui.dart';
import 'bankdepositsummary.dart';
import 'bankwithdrawalsummary.dart';
import 'momocashinsummary.dart';
import 'momowithdrawsummary.dart';

class AllSummaries extends StatelessWidget {
  const AllSummaries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Summaries"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: myBasicWidget("payment-method.png","Pay To",""),
                  onTap: () {
                    Get.to(() => const PayToSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: myBasicWidget("money-withdrawal.png","Cash In",""),

                  onTap: () {
                    Get.to(() => const MomoCashInSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: myBasicWidget("commission.png","Cash Out",""),
                  onTap: () {
                    Get.to(() => const MomoCashOutSummary());
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
                  child: myBasicWidget("bank.png","Deposit",""),

                  onTap: () {
                    Get.to(() => const BankDepositSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: myBasicWidget("bank.png","Withdrawals",""),

                  onTap: () {
                    Get.to(() => const BankWithdrawalSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: myBasicWidget("market-analysis.png","Report",""),

                  onTap: () {
                    Get.to(() => const MyReports());
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
