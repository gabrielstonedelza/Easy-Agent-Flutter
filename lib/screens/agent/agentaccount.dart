import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';

class AgentAccounts extends StatefulWidget {
  const AgentAccounts({Key? key}) : super(key: key);

  @override
  State<AgentAccounts> createState() => _AgentAccountsState();
}

class _AgentAccountsState extends State<AgentAccounts> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAccounts = [];

  Future<void> getAllMyAccounts(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_my_accounts/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyAccounts.assignAll(jsonData);
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
    getAllMyAccounts(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Accounts"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allMyAccounts != null ? allMyAccounts.length : 0,
          itemBuilder: (context, index) {
            items = allMyAccounts[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Bank: ", "bank"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Account No : ", "account_number"),
                    buildRow("Account Name : ", "account_name"),
                    buildRow("Branch : ", "branch"),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2),
                      child: Row(
                        children: [
                          const Text(
                            "Date added: ",
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: snackBackground,
      //   onPressed: (){
      //     Get.to(() => const AddAgentAccounts());
      //   },
      //   child: const Icon(Icons.add,size: 30,color: defaultWhite,),
      // ),
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

