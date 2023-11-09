import 'package:easy_agent/controllers/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../controllers/accountController.dart';
import '../../controllers/customerscontroller.dart';
import '../../widgets/loadingui.dart';
import '../dashboard.dart';
import '../sendsms.dart';

class PayToAgent extends StatefulWidget {
  const PayToAgent({Key? key}) : super(key: key);

  @override
  State<PayToAgent> createState() => _PayToAgentState();
}

class _PayToAgentState extends State<PayToAgent> {
  bool isPosting = false;
  final AccountController accountController = Get.find();
  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _agentPhoneController;
  late final TextEditingController _depositorPhoneController;
  late final TextEditingController _referenceController;
  FocusNode amountFocusNode = FocusNode();
  FocusNode agentPhoneFocusNode = FocusNode();
  FocusNode depositorPhoneFocusNode = FocusNode();
  FocusNode referenceFocusNode = FocusNode();
  late String uToken = "";
  final storage = GetStorage();
  bool isLoading = false;

  bool isMtn = false;
  late List allFraudsters = [];
  bool isFraudster = false;
  final SendSmsController sendSms = SendSmsController();

  Future<void> processPayToAgent() async {
    const registerUrl = "https://fnetagents.xyz/add_pay_to/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "amount": _amountController.text.trim(),
      "customer": _agentPhoneController.text.trim(),
      "depositor_number": _depositorPhoneController.text.trim(),
      "pay_to_type": "Agent",
      "reference": _referenceController.text.trim(),
    });

    if (res.statusCode == 201) {
      accountController.mtn =
          accountController.mtnNow - double.parse(_amountController.text);
      accountController.physical =
          accountController.physicalNow + double.parse(_amountController.text);
      accountController.airteltigo = accountController.airtelTigoNow;
      accountController.vodafone = accountController.vodafoneNow;

      addAccountsToday();
      String num = _depositorPhoneController.text.replaceFirst("0", '+233');
      if (accountController.companyName == "Fnet Enterprise") {
        sendSms.sendMySms(num, "FNET",
            "Amount GHC${_amountController.text} paid to agent ${_agentPhoneController.text} transaction was successful,.");
      } else {
        sendSms.sendMySms(num, "EasyAgent",
            "Amount GHC${_amountController.text} paid to agent ${_agentPhoneController.text} transaction was successful,.");
      }
      // sendSms.sendMySms(num, "EasyAgent","Amount GHC${_amountController.text} paid to agent ${_agentPhoneController.text} transaction was successful,");

      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      dialPayToAgent(_agentPhoneController.text.trim(),
          _amountController.text.trim(), _referenceController.text.trim());

      Get.offAll(() => const Dashboard());
    } else {
      Get.snackbar("Deposit Error", "something went wrong please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  Future<void> dialPayToAgent(
      String agentNumber, String amount, String reference) async {
    UssdAdvanced.multisessionUssd(
        code: "*171*1*1*$agentNumber*$agentNumber*$amount*$reference#",
        subscriptionId: 1);
  }

  final CustomersController controller = Get.find();

  final ProfileController profileController = Get.find();

  Future<void> addAccountsToday() async {
    const accountUrl = "https://fnetagents.xyz/add_balance_to_start/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": accountController.physical.toString(),
      "mtn_e_cash": accountController.mtn.toString(),
      "tigo_airtel_e_cash": accountController.airteltigo.toString(),
      "vodafone_e_cash": accountController.vodafone.toString(),
      "isStarted": "True",
      "agent": profileController.userId
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You accounts is updated",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
    } else {
      Get.snackbar("Account", "something happened",
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
    controller.getAllFraudsters(uToken);
    _amountController = TextEditingController();
    _depositorPhoneController = TextEditingController();
    _agentPhoneController = TextEditingController();
    _referenceController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _agentPhoneController.dispose();
    _referenceController.dispose();
    _depositorPhoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay to agent",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: snackBackground,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(18.0),
            child: Text(
              "Note: Please make sure to allow Easy Agent access in your phones accessibility before proceeding",
              style: TextStyle(fontWeight: FontWeight.bold, color: warning),
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
                      onChanged: (value) {
                        if (value.length == 10 &&
                            controller.fraudsterNumbers.contains(value)) {
                          setState(() {
                            isFraudster = true;
                          });
                          Get.snackbar("Customer Error",
                              "This customer is in the fraud lists.",
                              colorText: defaultWhite,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 10),
                              backgroundColor: warning);
                          Get.defaultDialog(
                              buttonColor: primaryColor,
                              title: "Fraud Alert",
                              middleText:
                                  "This customer is in the fraud list,continue",
                              confirm: RawMaterialButton(
                                  shape: const StadiumBorder(),
                                  fillColor: secondaryColor,
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.white),
                                  )),
                              cancel: RawMaterialButton(
                                  shape: const StadiumBorder(),
                                  fillColor: secondaryColor,
                                  onPressed: () {
                                    Get.offAll(() => const Dashboard());
                                  },
                                  child: const Text(
                                    "No",
                                    style: TextStyle(color: Colors.white),
                                  )));
                        } else {
                          setState(() {
                            isFraudster = false;
                          });
                        }
                      },
                      controller: _agentPhoneController,
                      focusNode: agentPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Agent's Number"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Agent's Phone Number";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
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
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _referenceController,
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
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _depositorPhoneController,
                      focusNode: depositorPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      cursorColor: secondaryColor,
                      decoration: buildInputDecoration("Depositor Phone"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter phone";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isPosting
                      ? const LoadingUi()
                      : !isFraudster
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RawMaterialButton(
                                fillColor: secondaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onPressed: () {
                                  _startPosting();
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  } else {
                                    processPayToAgent();
                                  }
                                },
                                child: const Text(
                                  "Send",
                                  style: TextStyle(
                                      color: defaultWhite,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Container(),
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
