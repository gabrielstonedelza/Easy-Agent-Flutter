import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../widgets/loadingui.dart';

class Commissions extends StatefulWidget {
  const Commissions({Key? key}) : super(key: key);

  @override
  State<Commissions> createState() => _CommissionsState();
}

class _CommissionsState extends State<Commissions> {
  DateTime now = DateTime.now();
  // DateTime date = DateTime(now.year, now.month, now.day);
  late double totalCommission = 0.0;
  late double cashReceived = 0.0;
  late double cashOutReceived = 0.0;
  late double cashInTotal = 0.0;
  late double cashOutTotal = 0.0;
  late double cashInCommissionTotalForToday = 0.0;
  late double cashOutCommissionTotalForToday = 0.0;

  final storage = GetStorage();
  late String uToken = "";
  late List allMtnDeposits = [];
  late List allMtnWithdrawals = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List depositsDates = [];



  fetchUserMtnDeposits() async {
    const url = "https://fnetagents.xyz/get_my_momo_deposits";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnDeposits = json.decode(jsonData);
      for (var i in allMtnDeposits) {
        if(i['date_deposited'].toString().split("T").first == now.toString().split(" ").first){
          cashInTotal = cashInTotal + double.parse(i['amount']);
          cashReceived = cashReceived + double.parse(i['cash_received']);
          cashInCommissionTotalForToday = cashReceived - cashInTotal;
        }
      }
      setState(() {
        isLoading = false;
      });
    }

  }

  fetchUserMtnWithdrawals()async{
    const url = "https://fnetagents.xyz/get_my_momo_withdraws";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnWithdrawals = json.decode(jsonData);
      for (var i in allMtnWithdrawals) {
        if(i['date_of_withdrawal'].toString().split("T").first == now.toString().split(" ").first){
          cashOutTotal = cashOutTotal + double.parse(i['amount']);
          cashOutReceived = cashOutReceived + double.parse(i['amount_received']);
          cashOutCommissionTotalForToday = cashOutReceived - cashOutTotal;
        }
      }
      setState(() {
        isLoading = false;
      });
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

    fetchUserMtnDeposits();
    fetchUserMtnWithdrawals();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Commission"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              height: 200,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom:18.0),
                      child: Center(
                        child: Text("Cash In",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                    ),
                    Text("CashIn Total Today = $cashInTotal",style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Cash Received Total Today = $cashReceived",style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Commission for today is",style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top:18.0),
                      child: Text("GHC $cashInCommissionTotalForToday",style: const TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              height: 200,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18.0),
                      child: Center(
                        child: Text("Cash Out",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                    ),
                    Text("CashOut Total Today = $cashOutTotal",style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Amount Received Total Today = $cashOutReceived",style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Commission for today is ",style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top:18.0),
                      child: Text("GHC $cashOutCommissionTotalForToday",style: const TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
