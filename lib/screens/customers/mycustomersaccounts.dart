import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';

class MyCustomersAccounts extends StatefulWidget {
  final phone_number;
  const MyCustomersAccounts({Key? key, required this.phone_number})
      : super(key: key);

  @override
  State<MyCustomersAccounts> createState() =>
      _MyCustomersAccountsState(phone_number: this.phone_number);
}

class _MyCustomersAccountsState extends State<MyCustomersAccounts> {
  final phone_number;
  _MyCustomersAccountsState({required this.phone_number});
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyCustomersAccounts = [];

  Future<void> getAllMyCustomersAccounts(String token) async {
    final url =
        "https://fnetagents.xyz/customer_accounts_details_by_phone_number/$phone_number/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyCustomersAccounts.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        print(response.body);
      }
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
    getAllMyCustomersAccounts(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$phone_number's accounts"),
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
              itemCount: allMyCustomersAccounts != null
                  ? allMyCustomersAccounts.length
                  : 0,
              itemBuilder: (context, index) {
                items = allMyCustomersAccounts[index];
                return Card(
                  color: secondaryColor,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: buildRow("Acc Name: ", "account_name"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRow("Acc No : ", "account_number"),
                        buildRow("Bank : ", "bank"),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 2, bottom: 10),
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
                                items['date_added'].toString().split("T").first,
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
      //     Get.to(() => const SearchCustomers());
      //   },
      //   child: const Icon(Icons.search_rounded,size: 30,color: defaultWhite,),
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
