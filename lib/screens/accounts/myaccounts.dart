import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/accounts/updateaccounts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/getonlineimage.dart';
import '../../widgets/loadingui.dart';
import '../summaries/accountsummary.dart';
import 'addaccountbalance.dart';
import 'closeaccount.dart';

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
  late List accountBalanceDetailsClosedToday = [];
  late List reversedAccountBalanceToday = List.of(accountBalanceDetailsToday.reversed);
  var items;
  bool hasClosedAccountToday = false;
  DateTime now = DateTime.now();

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
      for(var i in accountBalanceDetailsToday){
        if(i['date_posted'] == now.toString().split(" ").first && i['isClosed'] == true){
          hasClosedAccountToday = true;
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }
  Future<void> fetchAccountBalanceClosed() async {
    const postUrl = "https://fnetagents.xyz/get_my_account_balance_closed_today/";
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
      accountBalanceDetailsClosedToday.assignAll(allPosts);
      for(var i in accountBalanceDetailsClosedToday){
        if(i['date_closed'] == now.toString().split(" ").first && i['isClosed'] == true){
          hasClosedAccountToday = true;
        }
      }
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
    fetchAccountBalanceClosed();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Today"),
        actions: [
          // accountBalanceDetailsToday.isNotEmpty ? IconButton(
          //   onPressed: (){
          //     hasClosedAccountToday ? Get.snackbar("Error", "You have already closed accounts for today",
          //         colorText: defaultWhite,
          //         snackPosition: SnackPosition.BOTTOM,
          //         duration: const Duration(seconds: 5),
          //         backgroundColor: warning) :
          //     Get.to(()=> const CloseAccountBalance());
          //   },
          //   icon: myOnlineImage("wallet.png",70,70),
          // ) : Container(),
          accountBalanceDetailsToday.isNotEmpty ? IconButton(
            onPressed: (){
              hasClosedAccountToday ? Get.snackbar("Error", "You have already closed accounts for today therefore you can't edit.",
                  colorText: defaultWhite,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 5),
                  backgroundColor: warning) :
              Get.to(()=> const UpdateAccountBalance());
            },
            icon: myOnlineImage("pencil.png",70,70),
          ) : Container()
        ],
      ),
      body: isLoading ? const LoadingUi() : accountBalanceDetailsToday.isNotEmpty ? ListView.builder(
        reverse: true,
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

                        myOnlineImage("mon.png",30,30),
                        const Text(" = "),
                        Text(items['physical']),
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0,bottom: 10),
                          child: Row(
                            children: [
                              // myOnlineImage("assets/images/momo.png",30,30),
                              Image.asset("assets/images/momo.png",width: 30,height: 30,),
                              const Text(" = "),
                              Text(items['mtn_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              // myOnlineImage("assets/images/AIrtelTigo-Logo.png",30,30),
                              Image.asset("assets/images/AIrtelTigo-Logo.png",width: 30,height: 30,),
                              const Text(" = "),
                              Text(items['tigo_airtel_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              // myOnlineImage("assets/images/Vodafone-logo.png",30,30),
                              Image.asset("assets/images/Vodafone-logo.png",width: 30,height: 30,),
                              const Text(" = "),
                              Text(items['vodafone_e_cash']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Text("Working Capital : "),
                              const Text(" = "),
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
      ): Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You have not added an account for today",style: TextStyle(fontWeight: FontWeight.bold),),
            TextButton(
              onPressed: (){
                Get.to(() => const AddAccountBalance());
              },
              child: const Text("Add Accounts"),
            )
          ],
        ),
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
