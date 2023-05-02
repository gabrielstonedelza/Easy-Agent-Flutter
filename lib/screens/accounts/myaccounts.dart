import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/loadingui.dart';
import '../summaries/accountsummary.dart';
import 'addaccountbalance.dart';

class MyAccountDashboard extends StatefulWidget {
  const MyAccountDashboard({Key? key}) : super(key: key);

  @override
  State<MyAccountDashboard> createState() => _MyAccountDashboardState();
}

class _MyAccountDashboardState extends State<MyAccountDashboard> {
  bool isLoading = true;
  final storage = GetStorage();
  late String uToken = "";
  late List accountBalanceDetailsToday = [];
  var items;

  Future<void> fetchAccountBalance() async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_started_today/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      accountBalanceDetailsToday.assignAll(allPosts);
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchAccountBalance();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account Today"),
        actions: [
          IconButton(
            onPressed: (){
              Get.to(()=> const AddAccountBalance());
            },
            icon: const Icon(Icons.add_circle_rounded,size: 30,),
          )
        ],
      ),
      body: isLoading ? const LoadingUi() : accountBalanceDetailsToday.isNotEmpty ? ListView.builder(
        itemCount: accountBalanceDetailsToday != null ? accountBalanceDetailsToday.length:0,
          itemBuilder: (context,index){
            items = accountBalanceDetailsToday[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        const Text("Physical : "),
                        Text(items['physical']),
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,bottom: 10),
                          child: Row(
                            children: [
                              const Text("MTN : "),
                              Text(items['mtn_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Text("AirtelTigo : "),
                              Text(items['tigo_airtel_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Text("Vodafone : "),
                              Text(items['vodafone_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Text("Working Capital : "),
                              Text(items['e_cash_total'],style:const TextStyle(fontWeight: FontWeight.bold,color: warning)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Text("Time: "),
                              Text(items['time_posted'].toString().split(".").first),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ) : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text("You have not added an account to work with today"),
          ),
          const Center(
            child: Text("Please add accounts"),
          ),
          TextButton(
            onPressed: (){
              Get.to(() => const AddAccountBalance());
            },
            child: const Text("Add Accounts"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: (){
          Get.to(() => const AccountBalanceSummary());
        },
        child: const Text("All",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
      ),
    );
  }
}
