import 'dart:convert';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/balancing.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../widgets/loadingui.dart';
import 'balancingsummarydetail.dart';


class BalancingSummary extends StatefulWidget {
  const BalancingSummary({Key? key}) : super(key: key);

  @override
  State<BalancingSummary> createState() => _BalancingSummaryState();
}

class _BalancingSummaryState extends State<BalancingSummary> {
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBalancing = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List balancingDates = [];

  fetchAllBalancing()async{
    const url = "https://fnetagents.xyz/get_my_re_balancing_requests/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBalancing = json.decode(jsonData);

      for(var i in allBalancing){
        if(!balancingDates.contains(i['date_requested'].toString().split("T").first)){
          balancingDates.add(i['date_requested'].toString().split("T").first);
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
    fetchAllBalancing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Rebalancing Summary"),
          backgroundColor: secondaryColor,
        ),
        body: isLoading ? const LoadingUi() :
        ListView.builder(
            itemCount: balancingDates != null ? balancingDates.length : 0,
            itemBuilder: (context,i){
              items = balancingDates[i];
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return BalancingSummaryDetail(date_requested:balancingDates[i]);
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
            Get.to(() => const ReBalancing());
          },
        )
    );
  }
}
