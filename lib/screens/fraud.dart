import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import 'addfraudster.dart';

class Fraud extends StatefulWidget {
  const Fraud({Key? key}) : super(key: key);

  @override
  State<Fraud> createState() => _FraudState();
}

class _FraudState extends State<Fraud> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allFraudsters = [];

  Future<void> getAllFraudsters(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_all_fraudsters/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allFraudsters.assignAll(jsonData);
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
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
    getAllFraudsters(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fraudsters"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allFraudsters != null ? allFraudsters.length : 0,
          itemBuilder: (context, index) {
            items = allFraudsters[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Customer: ", "customer"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Reason : ", "reason"),
                    buildRow("Agent : ", "get_agents_username"),
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
          Get.to(() => const AddFraudster());
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
          Text(
            items[subtitle],
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
