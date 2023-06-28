import 'dart:convert';
import 'package:get/get.dart';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/payments/payrequest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/loadingui.dart';

class UnPaidRequests extends StatefulWidget {
  const UnPaidRequests({Key? key}) : super(key: key);

  @override
  State<UnPaidRequests> createState() => _UnPaidRequestsState();
}

class _UnPaidRequestsState extends State<UnPaidRequests> {
  final storage = GetStorage();
  bool isLoading = true;
  late String uToken = "";
  late List allUnpaidRequests = [];
  var items;

  Future<void> getAllUnPaidRequests() async {
    const profileLink = "https://fnetagents.xyz/get_unpaid_requests/";
    var link = Uri.parse(profileLink);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allUnpaidRequests = jsonData;

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
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllUnPaidRequests();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unpaid Requests"),
      ),
      body: isLoading  ? const LoadingUi() : ListView.builder(
        itemCount: allUnpaidRequests != null ? allUnpaidRequests.length:0,
          itemBuilder: (context,index){
            items = allUnpaidRequests[index];
            return Card(
              elevation: 12,
              color: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              child: ListTile(
                onTap: (){
                  Get.to(() => PayRequest(id:allUnpaidRequests[index]['id'].toString(),amount:allUnpaidRequests[index]['amount'],owner:allUnpaidRequests[index]['owner'].toString(),agent:allUnpaidRequests[index]['agent'].toString()));
                },
                title: buildRow("Amount: ", "amount"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    items["bank"] == "" ? Container():
                    buildRow("Bank: ", "bank"),
                    items["network"] == "" ? Container():
                    buildRow("Network: ", "network"),
                    buildRow("Approved: ", "request_approved"),
                    buildRow("Paid: ", "request_paid"),
                    items["reference"] == "" ? Container():
                    buildRow("Reference: ", "reference"),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 2),
                      child: Row(
                        children: [
                          const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(items['date_requested'].toString().split("T").first, style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding:  EdgeInsets.only(top:18.0,left: 8,bottom: 10),
                      child: Text("Tap to pay",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
  Padding buildRow(String mainTitle,String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(mainTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(items[subtitle].toString(), style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
