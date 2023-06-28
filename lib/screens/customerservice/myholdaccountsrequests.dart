import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import 'holdaccount.dart';

class MyRequestToHoldAccounts extends StatefulWidget {
  const MyRequestToHoldAccounts({Key? key}) : super(key: key);

  @override
  State<MyRequestToHoldAccounts> createState() => _MyRequestToHoldAccountsState();
}

class _MyRequestToHoldAccountsState extends State<MyRequestToHoldAccounts> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyRequests = [];

  Future<void> getAllMyRequestToHoldAccounts() async {
    const url = "https://fnetagents.xyz/get_all_my_request_to_hold_account/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyRequests.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllMyRequestToHoldAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests to hold accounts"),

      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allMyRequests != null ? allMyRequests.length : 0,
          itemBuilder: (context, index) {
            items = allMyRequests[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Amount: ", "amount"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Customer Number : ", "customer_number"),
                    buildRow("Reason : ", "reason"),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2),
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
                            items['date_added']
                                .toString()
                                .split("T")
                                .first,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: snackBackground,
        onPressed: (){
          Get.to(() => const HoldAccount());
        },
        child: const Icon(Icons.add,size: 30,color: defaultWhite,),
      ),
    );
  }

  Padding buildRow(String mainTitle, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            mainTitle,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Expanded(
            child: Text(
              items[subtitle],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
