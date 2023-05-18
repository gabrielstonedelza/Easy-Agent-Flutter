import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/screens/chats/agentsGroupchat.dart';
import 'package:easy_agent/screens/customerservice/fraud.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../widgets/loadingui.dart';


class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  final storage = GetStorage();

  late String username = "";
  late String uToken = "";
  var items;
  bool isLoading = true;
  List notifications = [];
  late List reversedNotifications = List.of(notifications.reversed);

  Future<void> getAllNotifications() async {
    const url = "https://fnetagents.xyz/get_my_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      notifications = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });

    } else {
      if (kDebugMode) {
        // print(response.body);
      }
    }
  }

  Future<void> readNotifications() async {
    const url = "https://fnetagents.xyz/read_notification/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      // final codeUnits = response.body.codeUnits;
      // var jsonData = const Utf8Decoder().convert(codeUnits);
      // notificationsUnread = json.decode(jsonData);
    } else {
      if (kDebugMode) {
        // print(response.body);
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
    getAllNotifications();
    readNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() : ListView.builder(
        itemCount: notifications != null ? notifications.length :0,
        itemBuilder: (context,index){
          items = notifications[index];
          return Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            ),
            child: Padding(
              padding: const EdgeInsets.only(top:8.0,bottom:8.0),
              child: ListTile(
                onTap: (){
                  if(notifications[index]['notification_title'] == "New fraud alert"){
                        Get.to(() => const Fraud());
                  }
                  if(notifications[index]['notification_title'] == "New group message"){
                    Get.to(() => const AgentsGroupChat());
                  }
                  if(notifications[index]['notification_title'] == "New private message"){
                    Get.to(() => const AgentsGroupChat());
                  }
                },
                title: Text(items['notification_title'],style: const TextStyle(fontWeight: FontWeight.bold,)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top:18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:18.0),
                        child: Text(items['notification_message']),
                      ),
                      Text(items['date_created'].toString().split("T").first),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ));
  }
}
