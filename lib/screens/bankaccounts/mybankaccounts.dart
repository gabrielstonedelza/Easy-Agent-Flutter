import 'dart:convert';

import 'package:easy_agent/screens/bankaccounts/updatebankaccounts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../widgets/loadingui.dart';



class MyBankAccounts extends StatefulWidget {
  const MyBankAccounts({Key? key}) : super(key: key);

  @override
  State<MyBankAccounts> createState() => _MyBankAccountsState();
}

class _MyBankAccountsState extends State<MyBankAccounts> {
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAccounts = [];

  Future<void> getAllMyBankAccounts() async {
    const url = "https://fnetagents.xyz/get_agent_accounts/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyAccounts.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
    else{
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
    getAllMyBankAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bank Accounts"),
        // backgroundColor: secondaryColor,
        actions: [
          IconButton(
            onPressed: (){
              getAllMyBankAccounts();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allMyAccounts != null ? allMyAccounts.length : 0,
          itemBuilder: (context, index) {
            items = allMyAccounts[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: secondaryColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  onTap: (){
                    Get.to(()=> UpdateMyAccount(id:allMyAccounts[index]['id'].toString(),acc_num:allMyAccounts[index]['account_number'],acc_name:allMyAccounts[index]['account_name'],bank:allMyAccounts[index]['bank'],phone_num:allMyAccounts[index]['phone'],linkedNum:allMyAccounts[index]['mtn_linked_number']));
                  },
                  title: buildRow("Bank: ", "bank"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRow("ACC No : ", "account_number"),
                      buildRow("Acc Name : ", "account_name"),
                      buildRow("Phone: ", "phone"),
                      buildRow("Linked Num : ", "mtn_linked_number"),
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
                      const SizedBox(height: 10,),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Tap to update accounts",style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
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
