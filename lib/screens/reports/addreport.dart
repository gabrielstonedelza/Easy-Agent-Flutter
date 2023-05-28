import 'dart:convert';

import 'package:easy_agent/constants.dart';
import 'package:easy_agent/controllers/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class AddNewReport extends StatefulWidget {
  const AddNewReport({Key? key}) : super(key: key);

  @override
  State<AddNewReport> createState() => _AddNewReportState();
}

class _AddNewReportState extends State<AddNewReport> {
  final SendSmsController sendSms = SendSmsController();
  late String uToken = "";
  final storage = GetStorage();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reportController;

  FocusNode reportFocusNode = FocusNode();


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
  late List ownerDetails = [];
  late String ownerId = "";

  bool isLoading = true;
  ProfileController controller = Get.find();
  List profileDetails = [];
  late String userId = "";
  late String agentPhone = "";
  late String ownerCode = "";
  late String agentUniqueCode = "";

  Future<void> getUserDetails() async {
    const profileLink = "https://fnetagents.xyz/get_user_details/";
    var link = Uri.parse(profileLink);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      profileDetails = jsonData;
      for(var i in profileDetails){
        userId = i['id'].toString();
        agentPhone = i['phone_number'];
        ownerCode = i['owner'];
        agentUniqueCode = i['agent_unique_code'];
      }
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

  addReport() async {
    const accountUrl = "https://fnetagents.xyz/post_report/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "report": _reportController.text.trim(),
      "owner": ownerId,
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "report was added",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds:5),
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {

      Get.snackbar("Error", "something happened",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
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
    _reportController = TextEditingController();
    getUserDetails();
    fetchOwnerWithCode();
  }

  @override
  void dispose(){
    super.dispose();
    _reportController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Report"),
        backgroundColor: secondaryColor,
      ),
      body:isLoading
          ? const LoadingUi()
          : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      maxLines: 5,
                      controller: _reportController,
                      focusNode: reportFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Report"),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter report";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30,),
                  isPosting  ? const LoadingUi() :

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawMaterialButton(
                      fillColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      onPressed: (){
                        _startPosting();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (!_formKey.currentState!.validate()) {
                          return;
                        } else {
                          addReport();
                        }
                      },child: const Text("Save",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
