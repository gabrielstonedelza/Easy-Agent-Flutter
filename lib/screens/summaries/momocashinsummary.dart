import 'package:easy_agent/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../controllers/accountController.dart';
import 'momodepositsummarydetail.dart';

class MomoCashInSummary extends StatefulWidget {
  const MomoCashInSummary({Key? key}) : super(key: key);

  @override
  State<MomoCashInSummary> createState() => _MomoCashInSummaryState();
}

class _MomoCashInSummaryState extends State<MomoCashInSummary> {
  final storage = GetStorage();
  late String uToken = "";

  var items;

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
      appBar: AppBar(
        title: const Text("Mtn Deposit Summary"),
      ),
      body: GetBuilder<AccountController>(builder: (controller) {
        return ListView.builder(
            itemCount: controller.mtnDepositDates != null
                ? controller.mtnDepositDates.length
                : 0,
            itemBuilder: (context, i) {
              items = controller.mtnDepositDates[i];
              return Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MtnDepositSummaryDetail(
                            deposit_date: controller.mtnDepositDates[i]);
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  const Text(
                                    "Date: ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    items,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            });
      }),
    );
  }
}
