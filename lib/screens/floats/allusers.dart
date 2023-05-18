import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/profilecontroller.dart';
import '../../widgets/loadingui.dart';
import '../chats/privatechat.dart';


class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  late List allMyOwnersAgents = [];
  late List allAgents = [];
  bool isLoading = true;
  late var items;

  String profileId = "";
  final storage = GetStorage();
  late String uToken = "";
  final ProfileController controller = Get.find();

  fetchAllMyOwnerAgents()async{
    final url = "https://fnetagents.xyz/get_supervisor_agents/${controller.ownerCode}/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink,headers: {"Authorization": "Token $uToken"});

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMyOwnersAgents = json.decode(jsonData);
      // for(var i in allMyOwnersAgents){
      //   if(i['phone_number'] != controller.agentPhone){
      //    if(!allAgents.contains(i)){
      //      allAgents.add(i);
      //    }
      //   }
      //
      //   print(allAgents);
      // }
      setState(() {
        isLoading = false;
      });
    }

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
    if (storage.read("profile_id") != null) {
      setState(() {

        profileId = storage.read("profile_id");
      });
    }
    fetchAllMyOwnerAgents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Private chat agents"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh_rounded),
        //     onPressed: () {
        //       setState(() {
        //         isLoading = true;
        //       });
        //       fetchAllMyOwnerAgents();
        //     },
        //   )
        // ],
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: allMyOwnersAgents != null ? allMyOwnersAgents.length : 0,
              itemBuilder: (context,i){
                items = allMyOwnersAgents[i];
                return Column(
                  children: [
                    const SizedBox(height: 10,),
                    items['phone_number']  == controller.agentPhone ? Container() :  Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: ListTile(
                            onTap: (){
                              Get.to(()=> PrivateChat());
                            },
                            leading: const CircleAvatar(
                                backgroundColor: primaryColor,
                                // foregroundColor: Colors.white,
                                child: Icon(Icons.person,color: snackBackground,)
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(items['username'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                            ),
                            // subtitle: Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text(items['company_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                            //   ],
                            // ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,)
                  ],
                );
              }
          )
      ),

    );
  }
}
