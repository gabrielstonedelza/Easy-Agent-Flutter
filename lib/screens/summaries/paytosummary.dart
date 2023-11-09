import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/summaries/paytoagentsummarydetail.dart';
import 'package:easy_agent/screens/summaries/paytosummaryformerchantdetail.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../controllers/accountController.dart';

class PayToSummary extends StatefulWidget {
  const PayToSummary({Key? key}) : super(key: key);

  @override
  State<PayToSummary> createState() => _PayToSummaryState();
}

class _PayToSummaryState extends State<PayToSummary> {
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";

  late List allPayToForMerchants = [];
  var items;
  var merchatItems;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: snackBackground,
            bottom: TabBar(
              indicatorColor: snackBackground,
              tabs: [
                Tab(
                  child: Column(
                    children: [
                      GetBuilder<AccountController>(builder: (controller) {
                        return Text(
                            "Agents (${controller.date_added_for_agent.length})",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white));
                      }),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      GetBuilder<AccountController>(builder: (controller) {
                        return Text(
                            "Agents (${controller.date_added_for_merchant.length})",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white));
                      })
                    ],
                  ),
                ),
              ],
            ),
            title: const Text('Pay To Summary'),
          ),
          body: TabBarView(
            children: [
              GetBuilder<AccountController>(builder: (controller) {
                return ListView.builder(
                  itemCount: controller.date_added_for_agent != null
                      ? controller.date_added_for_agent.length
                      : 0,
                  itemBuilder: (BuildContext context, int index) {
                    items = controller.date_added_for_agent[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 12,
                        color: secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Get.to(() => PayToAgentSummaryDetail(
                                  date_added:
                                      controller.date_added_for_agent[index]));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: defaultWhite)),
                                const SizedBox(width: 10),
                                Text(items,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: defaultWhite)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              GetBuilder<AccountController>(builder: (controller) {
                return ListView.builder(
                  itemCount: controller.date_added_for_merchant != null
                      ? controller.date_added_for_merchant.length
                      : 0,
                  itemBuilder: (BuildContext context, int index) {
                    merchatItems = controller.date_added_for_merchant[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 12,
                        color: secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              Get.to(() => PayToMerchantSummaryDetail(
                                  date_added: controller
                                      .date_added_for_merchant[index]));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: defaultWhite)),
                                const SizedBox(width: 10),
                                Text(merchatItems,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: defaultWhite)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
