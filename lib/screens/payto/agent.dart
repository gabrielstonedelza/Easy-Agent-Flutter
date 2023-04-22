import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

import '../dashboard.dart';

class PayToAgent extends StatefulWidget {
  const PayToAgent({Key? key}) : super(key: key);

  @override
  State<PayToAgent> createState() => _PayToAgentState();
}

class _PayToAgentState extends State<PayToAgent> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _agentPhoneController;
  late final TextEditingController _referenceController;
  FocusNode amountFocusNode = FocusNode();
  FocusNode agentPhoneFocusNode = FocusNode();
  FocusNode referenceFocusNode = FocusNode();

  Future<void> dialPayToAgent(String agentNumber,String amount,String reference) async {
    UssdAdvanced.multisessionUssd(code: "*171*1*1*$agentNumber*$agentNumber*$amount*$reference#",subscriptionId: 1);
  }

  @override
  void initState(){
    super.initState();
    _amountController = TextEditingController();
    _agentPhoneController = TextEditingController();
    _referenceController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _agentPhoneController.dispose();
    _referenceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay to agent",style:TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: ListView(
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
                      controller: _agentPhoneController,
                      focusNode: agentPhoneFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Agent's Phone Number",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter Agent's Phone Number";
                        }
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
                      decoration: InputDecoration(

                          labelText: "Amount",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
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
                      controller: _referenceController,
                      focusNode: referenceFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Reference",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter reference";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30,),
                  RawMaterialButton(
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        dialPayToAgent(_agentPhoneController.text.trim(),_amountController.text.trim(),_referenceController.text.trim());
                        Get.offAll(() => const Dashboard());
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: Colors.amber,
                    splashColor: Colors.amberAccent,
                    child: const Text(
                      "Send",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
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
}
