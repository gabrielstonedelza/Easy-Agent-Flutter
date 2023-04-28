import 'dart:convert';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/bank/bankdeposit.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/loadingui.dart';
import '../bank/bankwithdrawal.dart';
import 'bankwithdrawalsummarydetail.dart';


class BankWithdrawalSummary extends StatefulWidget {
  const BankWithdrawalSummary({Key? key}) : super(key: key);

  @override
  State<BankWithdrawalSummary> createState() => _BankWithdrawalSummaryState();
}

class _BankWithdrawalSummaryState extends State<BankWithdrawalSummary> {
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBankWithdrawals = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List bankWithdrawalDates = [];

  fetchAllBankWithdrawals()async{
    const url = "https://fnetagents.xyz/get_my_bank_withdrawals/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBankWithdrawals = json.decode(jsonData);

      for(var i in allBankWithdrawals){
        if(!bankWithdrawalDates.contains(i['date_of_withdrawal'].toString().split("T").first)){
          bankWithdrawalDates.add(i['date_of_withdrawal'].toString().split("T").first);
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchAllBankWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bank Withdrawal Summary"),
          backgroundColor: secondaryColor,
        ),
        body: isLoading ? const LoadingUi() :
        ListView.builder(
            itemCount: bankWithdrawalDates != null ? bankWithdrawalDates.length : 0,
            itemBuilder: (context,i){
              items = bankWithdrawalDates[i];
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return BankWithdrawalSummaryDetail(date_of_withdrawal:bankWithdrawalDates[i]);
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

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
            }
        ),
        floatingActionButton:FloatingActionButton(
          backgroundColor: secondaryColor,
          child: const Icon(Icons.add,size: 30,),
          onPressed: (){
            Get.to(() => const BankWithdrawal());
          },
        )
    );
  }
}
