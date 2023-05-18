import 'dart:async';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:easy_agent/constants.dart';
import 'package:easy_agent/controllers/profilecontroller.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:grouped_list/grouped_list.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../floats/allusers.dart';

class AgentsGroupChat extends StatefulWidget {
  const AgentsGroupChat({Key? key}) : super(key: key);

  @override
  State<AgentsGroupChat> createState() => _AgentsGroupChatState();
}

class _AgentsGroupChatState extends State<AgentsGroupChat> {
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  List groupMessages = [];
  bool isLoading = true;
  late Timer _timer;
  late final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final ProfileController controller = Get.find();
  late List ownerDetails = [];
  late String ownerId = "";

  sendGroupMessage() async {
    const bidUrl = "https://fnetagents.xyz/send_agents_group_message/";
    final myLink = Uri.parse(bidUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "message": messageController.text,
      "agent": controller.userId,
      "owner": ownerId,
    });
    if (response.statusCode == 201) {
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  fetchAllGroupMessages() async {
    final url = "https://fnetagents.xyz/get_agents_group_messages/$ownerId/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      groupMessages = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }
  fetchOwnerWithCode() async {
    final url = "https://fnetagents.xyz/get_supervisor_with_code/${controller.ownerCode}/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      ownerDetails = json.decode(jsonData);
      for(var i in ownerDetails){
        ownerId = i['id'].toString();
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("token");
      });
    }
    fetchAllGroupMessages();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchAllGroupMessages();
    });
    fetchOwnerWithCode();
  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.grey,
            appBar: AppBar(
              title: const Text("Agents Group Chats"),
              backgroundColor: secondaryColor,

            ),
            body: Column(
              children: [
                Expanded(
                  child: GroupedListView<dynamic, String>(
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    order: GroupedListOrder.DESC,
                    elements: groupMessages,
                    groupBy: (element) =>
                    element['timestamp'].toString().split("T").first,
                    groupSeparatorBuilder: (String groupByValue) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        groupByValue,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    // groupHeaderBuilder: (),
                    itemBuilder: (context, dynamic element) => SlideInUp(
                      animate: true,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 12,
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 18.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Text(
                                        //   element['get_phone_number'],
                                        //   style: const TextStyle(
                                        //       fontSize: 12,
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                        Text(
                                          element['get_agent_username'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 18.0),
                                    child: SelectableText(
                                      element['message'],
                                      showCursor: true,
                                      cursorColor: Colors.blue,
                                      cursorRadius: const Radius.circular(10),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        element['timestamp']
                                            .toString()
                                            .split("T")
                                            .first,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        element['timestamp']
                                            .toString()
                                            .split("T")
                                            .last
                                            .substring(0, 8),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ))),
                    ),
                    // itemComparator: (item1, item2) => item1['get_username'].compareTo(item2['get_username']), // optional
                    useStickyGroupSeparators: true, // optional
                    floatingHeader: true, // optional
                    // order: GroupedListOrder.ASC, // optional
                  ),
                ),
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: TextFormField(
                          controller: messageController,
                          focusNode: messageFocusNode,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 5,
                          maxLines: null,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: secondaryColor,
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (messageController.text == "") {
                                    Get.snackbar("Sorry",
                                        "message field cannot be empty",
                                        snackPosition: SnackPosition.TOP,
                                        colorText: secondaryColor,
                                        backgroundColor: Colors.red);
                                  } else {
                                    sendGroupMessage();
                                    messageController.text = "";
                                  }
                                },
                              ),
                              hintText: "Message here.....",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent, width: 2),
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
