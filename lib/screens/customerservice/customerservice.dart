import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/customerservice/fraud.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/getonlineimage.dart';
import 'mycomplains.dart';
import 'myholdaccountsrequests.dart';


class CustomerService extends StatelessWidget {
  const CustomerService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Service"),
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
                  myOnlineImage("assets/images/sad.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Complains"),
                    ],
                  ),
                  onTap: () {
                    Get.to(()=> const MyComplains());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("assets/images/hold.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Hold Account"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const MyRequestToHoldAccounts());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("assets/images/fraud-alert.png",70,70),
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
            ],
          ),
        ],
      ),
    );
  }
}
