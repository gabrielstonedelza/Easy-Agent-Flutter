import 'package:easy_agent/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../widgets/loadingui.dart';
import '../dashboard.dart';

class PayRequest extends StatefulWidget {
  final id;
  final amount;
  final agent;
  final owner;
  const PayRequest(
      {Key? key,
      required this.id,
      required this.amount,
      required this.agent,
      required this.owner})
      : super(key: key);

  @override
  State<PayRequest> createState() => _PayRequestState(
      id: this.id, amount: this.amount, agent: this.agent, owner: this.owner);
}

class _PayRequestState extends State<PayRequest> {
  final id;
  final amount;
  final agent;
  final owner;
  _PayRequestState(
      {required this.id,
      required this.amount,
      required this.agent,
      required this.owner});

  late String uToken = "";
  late List allRequests = [];
  final storage = GetStorage();
  bool isPosting = false;
  late final TextEditingController amountController;
  late final TextEditingController referenceController;

  FocusNode amountFocusNode = FocusNode();
  FocusNode referenceFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  makePayment() async {
    const requestUrl = "https://fnetagents.xyz/make_request_payment/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "amount": amountController.text.trim(),
      "reference": referenceController.text.trim(),
      "agent": agent,
      "owner": owner,
    });
    if (response.statusCode == 201) {
      updateRequest();
      Get.snackbar("Success", "payment was approved",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {
      print(response.body);
      Get.snackbar("Approve Error", "something happened. Please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  updateRequest() async {
    final requestUrl = "https://fnetagents.xyz/update_agent_request/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "request_paid": "Approved",
      "amount": amount,
      "agent": agent,
      "owner": owner,
    });
    if (response.statusCode == 200) {
      Get.snackbar("Success", "request was paid and sent for approval",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);

      // Get.offAll(() => const Dashboard());
    } else {
      // print(response.body);
      Get.snackbar("Approve Error", "something happened. Please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    amountController = TextEditingController();
    referenceController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    referenceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay your request"),
        backgroundColor: secondaryColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:18.0,bottom: 18),
            child: Center(
              child: Text("Amount to pay is $amount"),
            ),
          ),
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
                      controller: amountController,
                      focusNode: amountFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Amount"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: referenceController,
                      focusNode: referenceFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Reference"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter reference";
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isPosting
                      ? const LoadingUi()
                      : NeoPopTiltedButton(
                          isFloating: true,
                          onTapUp: () {
                            _startPosting();
                            FocusScopeNode currentFocus = FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else {
                              if (int.parse(amountController.text) != int.parse(amount.toString().split(".").first)) {
                                Get.snackbar("Amount Error", "Your amount doesn't match your request amount,go back and check",
                                colorText: defaultWhite,
                                backgroundColor: warning,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5));
                                return;
                              } else {
                                makePayment();
                              }
                            }
                          },
                          decoration: const NeoPopTiltedButtonDecoration(
                            color: secondaryColor,
                            plunkColor: Color.fromRGBO(255, 235, 52, 1),
                            shadowColor: Color.fromRGBO(36, 36, 36, 1),
                            showShimmer: true,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 70.0,
                              vertical: 15,
                            ),
                            child: Text('Save',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white)),
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
