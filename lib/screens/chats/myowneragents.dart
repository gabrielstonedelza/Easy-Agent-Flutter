import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import 'agentsprivatechat.dart';

class AllOwnerUsers extends StatefulWidget {
  const AllOwnerUsers({Key? key}) : super(key: key);

  @override
  _AllOwnerUsersState createState() => _AllOwnerUsersState();
}

class _AllOwnerUsersState extends State<AllOwnerUsers> {
  late List allUsers = [];
  bool isLoading = true;
  late var items;
  late List agentsNames = [];
  late String username = "";
  String profileId = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  final ProfileController profileController = Get.find();

  late List supervisorDetails = [];
  late String supervisorId = "";
  late String supervisorUsername = "";

  Future<void> fetchSuperVisorsDetails() async {
    final postUrl =
        "https://fnetagents.xyz/get_supervisor_with_code/${profileController.ownerCode}/";
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
      supervisorDetails.assignAll(allPosts);
      for (var i in supervisorDetails) {
        supervisorId = i['id'].toString();
        supervisorUsername = i['username'];
      }
      fetchAllMyOwnerUsers(supervisorUsername);
      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }

  Future<void> fetchAllMyOwnerUsers(String ownerUsername) async {
    final url = "https://fnetagents.xyz/get_supervisor_agents/$ownerUsername/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUsers = json.decode(jsonData);
      for (var i in agentsNames) {
        if (!agentsNames.contains(i['username'])) {
          agentsNames.add(i['username']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allUsers = allUsers;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchSuperVisorsDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchAllMyOwnerUsers(supervisorUsername);
            },
          )
        ],
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
                  itemCount: allUsers != null ? allUsers.length : 0,
                  itemBuilder: (context, i) {
                    items = allUsers[i];
                    return Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Card(
                            color: secondaryColor,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            // shadowColor: Colors.pink,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: allUsers[i]['username'] !=
                                      profileController.agentUsername
                                  ? ListTile(
                                      onTap: () {
                                        // String telnum = allUsers[i]['phone'];
                                        // telnum = telnum.replaceFirst("0", '+233');
                                        // launchWhatsapp(message: "Hello", number: telnum);
                                        Get.to(() => AgentPrivateChat(
                                            receiverUserName: allUsers[i]
                                                ['username'],
                                            receiverId:
                                                allUsers[i]['id'].toString()));
                                        // print(allUsers[i]['id'].toString());
                                      },
                                      leading: const CircleAvatar(
                                          backgroundColor: secondaryColor,
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.person)),
                                      title: Text(
                                        items['username'],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      // subtitle: Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(items['company_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                      //   ],
                                      // ),
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    );
                  })),
    );
  }
}
