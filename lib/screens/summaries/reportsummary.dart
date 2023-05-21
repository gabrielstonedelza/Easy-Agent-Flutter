import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../reports/addreport.dart';

class MyReports extends StatefulWidget {
  const MyReports({Key? key}) : super(key: key);

  @override
  State<MyReports> createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyReports = [];

  Future<void> getAllMyReports(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_my_reports/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyReports.assignAll(jsonData);
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

  deletePayment(String id) async {
    final url = "https://fnetagents.xyz/delete_report/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 204) {
      // Get.offAll(() => const Dashboard());
    } else {

    }
  }
  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllMyReports(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allMyReports != null ? allMyReports.length : 0,
          itemBuilder: (context, index) {
            items = allMyReports[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Date: ", "date_reported"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left:8.0,bottom: 8),
                      child: Text("Report : ",style: TextStyle(fontWeight: FontWeight.bold,color: defaultWhite),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0,top: 8,bottom: 8),
                      child: Text(items['report'],style: TextStyle(fontWeight: FontWeight.bold,color: defaultWhite)),
                    )
                  ],
                ),
                trailing: IconButton(
                  icon: Image.asset("assets/images/cancel.png",width: 30,height: 30,),
                  onPressed: (){
                    _startPosting();
                    getAllMyReports(uToken);
                    deletePayment(allMyReports[index]['id'].toString());
                  },
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: snackBackground,
        onPressed: (){
          Get.to(() => const AddNewReport());
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
          Expanded(
            child: Text(
              items[subtitle],
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
